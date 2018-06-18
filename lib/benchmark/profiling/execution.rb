module Benchmark
  class Profiling
    class Execution < Matching

      def initialize(label, num, round, process_num, file_path)
        super(label, num, round, file_path)
        @process_num = process_num
      end

      def execute_trades
        t1 = Trade.count

        @instructions.in_groups(@process_num, false).each_with_index do |insts, i|
          unless Process.fork
            ActiveRecord::Base.connection.reconnect!
            file = File.open(@file_path, "a")
            file.puts "Executor #{i+1} started."
            puts "Executor #{i+1} started."

            t1 = Time.now
            insts.each do |payload|
              ::Matching::Executor.new(payload).execute!
            end

            file.puts "Executor #{i+1} finished work, stop."
            file.close
            puts "Executor #{i+1} finished work, stop."
            exit 0
          end
        end
        pid_and_status = Process.waitall

        ActiveRecord::Base.connection.reconnect!
        @trades = Trade.count - t1

      end

      def run_execute_trades
        puts "\n>> Execute Trade Instructions"

        file = File.open(@file_path, "a")
        file.puts "************ Execute Trades Results ********"
        file.puts RubyProf::FlatPrinter.new(RubyProf.profile { execute_trades }).print(file)
        str = "#{@instructions.size} trade instructions executed by #{@process_num} executors, #{@trades} trade created."

        file.puts str
        file.close
      end
    end
  end
end