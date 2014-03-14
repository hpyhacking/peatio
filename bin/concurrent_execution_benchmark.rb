#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require_relative 'matching_benchmark'

class ConcurrentExecuteBenchmark < MatchingBenchmark

  def initialize(label, num, round, process_num)
    super(label, num, round)
    @process_num = process_num
  end

  def execute_trades
    t1 = Trade.count

    market = Market.find('cnybtc')
    @instructions.in_groups(@process_num, false).each_with_index do |insts, i|
      unless Process.fork
        ActiveRecord::Base.connection.reconnect!
        puts "Executor #{i+1} started."

        insts.each do |(ask, bid, strike_price, volume)|
          ::Matching::Executor.new(market, ask, bid, strike_price, volume).execute!
        end

        puts "Executor #{i+1} finished work, stop."
        exit 0
      end
    end
    pid_and_status = Process.waitall

    ActiveRecord::Base.connection.reconnect!
    @trades = Trade.count - t1
    pid_and_status
  end

  def run_execute_trades
    puts "\n>> Execute Trade Instructions"
    Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
      t = x.report { execute_trades }
      @times[:execution] = [t]
      puts "#{@instructions.size} trade instructions executed by #{@process_num} executors, #{@trades} trade created."
    end
  end

end


if $0 == __FILE__
  raise "Must run in test environment!" unless Rails.env.test?

  process_num = ARGV[0] ? ARGV[0].to_i : 8
  num = ARGV[1] ? ARGV[1].to_i : 250
  round = ARGV[2] ? ARGV[2].to_i : 4
  label = ARGV[3] || Time.now.to_i

  puts "\n>> Setup environment"
  system("rake db:reset")
  Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }

  ConcurrentExecuteBenchmark.new(label, num, round, process_num).run
end
