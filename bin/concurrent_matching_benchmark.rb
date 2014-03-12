#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
raise "Must run in test environment!" unless Rails.env.test?

require 'fileutils'
require_relative 'matching_benchmark'

class ConcurrentMatchingBenchmark < MatchingBenchmark

  def run
    puts "\n>> Create Orders"
    Benchmark.benchmark(Benchmark::CAPTION, 10, Benchmark::FORMAT) do |x|
      @times[:create] = (1..@round).map do |i|
        x.report("Round #{i}") do
          create_orders
        end
      end

      nil
    end

    File.open(Rails.root.join('tmp', "concurrent_benchmark_#{@label}"), 'w') do |f|
      utime_avg = @times[:create].map(&:utime).sum / @round
      stime_avg = @times[:create].map(&:stime).sum / @round
      real_avg  = @times[:create].map(&:real).sum  / @round
      f.puts "#{utime_avg} #{stime_avg} #{real_avg}"

      puts "\n>> Average throughput (orders per second)"
      puts "create: %.2fops" % (@num/real_avg)
    end
  end

end

process_num = ARGV[0] ? ARGV[0].to_i : 8
num = ARGV[1] ? ARGV[1].to_i : 100
round = ARGV[2] ? ARV[2].to_i : 3
total = num*round*process_num

puts "\n>> Concurrent Create #{total} Orders Benchmark (process number: #{process_num})"

puts "\n>> Setup environment"
system("rake db:reset")
Dir[Rails.root.join('tmp', 'concurrent_benchmark_*')].each {|f| FileUtils.rm(f) }

t1 = Time.now.to_f
process_num.times do
  unless Process.fork
    $stdout = File.new Rails.root.join('log', "concurrent_benchmark.#{Process.pid}.log"), 'w'
    ConcurrentMatchingBenchmark.new(Process.pid, num, round).run
    exit 0
  end
end

puts "\n>> Wait child processes to finish .."
pid_and_status = Process.waitall
elapsed = Time.now.to_f - t1

puts "\n>> Results"
pid_and_status.each do |(pid, status)|
  lines = File.readlines Rails.root.join('tmp', "concurrent_benchmark_#{pid}")
  create_avg = lines.first.strip.split(' ').last.to_f
  puts "%10s %.2f" % [status, create_avg]
end
puts "%10s %.2f" % ['Total', elapsed]

puts "\n>> Concurrent Throughput (orders per second)"
puts "create: %.2fops" % (total.to_f/elapsed)
