require_relative 'amqp_mock'

module Benchmark
  class Matching
    include Helpers

    def initialize(label, num, round)
      @label = label.to_s
      @num = num
      @round = round
      @times = Hash.new {|h,k| h[k] = [] }
    end

    def run
      run_prepare_orders
      run_matching_orders
      run_execute_trades
      save
    end

    def run_prepare_orders
      (1..@round).map do |i|
        puts "\n>> Round #{i}"
        Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
          @times[:create_members] << x.report("create members") { create_members }
          @times[:lock_funds]     << x.report("lock funds") { lock_funds }
          @times[:create_orders]  << x.report("create orders") { create_orders }
          nil
        end
      end
    end

    def run_matching_orders
      puts "\n>> Match Them All"
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        t = x.report { matching_orders }
        @times[:matching] = [t]
        puts "#{@matches} matches run for #{@processed} orders, #{@instructions.size} trade instruction generated."
      end
    end

    def run_execute_trades
      puts "\n>> Execute Trade Instructions"
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        t = x.report { execute_trades }
        @times[:execution] = [t]
        puts "#{@instructions.size} trade instructions executed, #{@trades} trade created."
      end
    end

    def save
      avg = {}

      File.open(Rails.root.join('tmp', "matching_result_#{@label}"), 'w') do |f|
        @times.each do |k, v|
          avg[k] = averages(v)
          f.puts avg[k].join(" ")
        end
      end

      puts "\n>> Average throughput (ops: orders per second, eps: execution per second)"
      puts "create members: %.2fops" % [@num/avg[:create_members].last]
      puts "lock funds:     %.2fops" % [@num/avg[:lock_funds].last]
      puts "create orders:  %.2fops" % [@num/avg[:create_orders].last]
      puts "submit orders:  %.2fops" % [@num/(avg[:lock_funds].last+avg[:create_orders].last)]
      puts "matching:       %.2fops" % [@processed/avg[:matching].last] if avg[:matching]
      puts "execution:      %.2feps" % [@instructions.size/avg[:execution].last] if avg[:execution]
      puts "* submit order = lock funds + create order"
    end

    def averages(times)
      utime_avg = times.map(&:utime).sum / times.size
      stime_avg = times.map(&:stime).sum / times.size
      real_avg  = times.map(&:real).sum  / times.size
      [utime_avg, stime_avg, real_avg]
    end

  end
end
