#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require_relative 'matching_benchmark'

class ConcurrentCreateOrderBenchmark < MatchingBenchmark

  def initialize(label, num, round, process_num)
    super(label, num, round)
    @process_num = process_num
  end

  def collect_time
    time = Dir[Rails.root.join('tmp', 'concurrent_create_order_*')].map do |f|
      File.open(f, 'r') {|ff| ff.read.to_f }
    end.max
    puts "elapsed: #{time}"
    Benchmark::Tms.new(0, 0, 0, 0, time)
  end

  def create_orders
    members = Member.all
    members.in_groups(@process_num, false).each_with_index do |users, i|
      unless Process.fork
        ActiveRecord::Base.connection.reconnect!
        puts "Process #{i+1} started."

        t1 = Time.now
        users.each {|m| SweatFactory.make_ask_order(m, 10, 4000) }
        elapsed = Time.now - t1
        File.open(Rails.root.join('tmp', "concurrent_create_order_#{i+1}"), 'w') {|f| f.write(elapsed.to_f) }

        puts "Process #{i+1} finished, stop."
        exit 0
      end
    end

    pid_and_status = Process.waitall
    ActiveRecord::Base.connection.reconnect!

    collect_time
  end

  def run_prepare_orders
    (1..@round).map do |i|
      puts "\n>> Round #{i}"
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        @times[:create_members] << x.report("create members") { create_members }
        @times[:lock_funds]     << x.report("lock funds") { lock_funds }
        nil
      end
    end
  end

  def run
    run_prepare_orders

    Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
      @times[:create_orders] = [ create_orders ]
      puts "#{Order.count} orders created by #{@process_num} processes."
    end

    save
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
  Dir[Rails.root.join('tmp', 'concurrent_create_order_*')].each {|f| FileUtils.rm(f) }

  ConcurrentCreateOrderBenchmark.new(label, num, round, process_num).run
end
