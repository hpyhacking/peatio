require_relative 'amqp_mock'

module Benchmark
  class Execution < Matching

    def initialize(label, num, round, process_num)
      super(label, num, round)
      @process_num = process_num
    end

    def collect_time
      time = Dir[Rails.root.join('tmp', 'concurrent_executor_*')].map do |f|
        File.open(f, 'r') {|ff| ff.read.to_f }
      end.max
      puts "elapsed: #{time}"
      Benchmark::Tms.new(0, 0, 0, 0, time)
    end

    def execute_trades
      t1 = Trade.count

      @instructions.in_groups(@process_num, false).each_with_index do |insts, i|
        unless Process.fork
          ActiveRecord::Base.connection.reconnect!
          puts "Executor #{i+1} started."

          t1 = Time.now
          insts.each do |payload|
            ::Matching::Executor.new(payload).execute!
          end
          elapsed = Time.now - t1
          File.open(Rails.root.join('tmp', "concurrent_executor_#{i+1}"), 'w') {|f| f.write(elapsed.to_f) }

          puts "Executor #{i+1} finished work, stop."
          exit 0
        end
      end
      pid_and_status = Process.waitall

      ActiveRecord::Base.connection.reconnect!
      @trades = Trade.count - t1

      collect_time
    end

    def run_execute_trades
      puts "\n>> Execute Trade Instructions"
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        @times[:execution] = [ execute_trades ]
        puts "#{@instructions.size} trade instructions executed by #{@process_num} executors, #{@trades} trade created."
      end
    end

  end
end
