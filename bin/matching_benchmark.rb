#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'test'

require 'benchmark'
require_relative '../config/environment'

class SweatFactory

  @@seq = 0

  class <<self
    def make_member
      @@seq += 1
      member = Member.create!(
        email: "user#{@@seq}@example.com",
        name: "Matching Benchmark #{@@seq}"
      )
    end

    def make_ask_order(volume, price)
      member = make_member
      member.get_account(:btc).update_attributes(
        locked: volume.to_d, balance: rand(100).to_d)

      make_order(OrderAsk, volume: volume, price: price, member: member)
    end

    def make_bid_order(volume, price)
      member = make_member
      member.get_account(:cny).update_attributes(
        locked: volume.to_d*price.to_d, balance: rand(10000).to_d)

      make_order(OrderBid, volume: volume, price: price, member: member)
    end

    def make_order(klass, attrs={})
      klass.create!({
        bid: :cny,
        ask: :btc,
        currency: :cnybtc,
        state: :wait,
        origin_volume: attrs[:volume]
      }.merge(attrs))
    end
  end

end

class MatchingBenchmark

  def initialize(label, num, round)
    @label = label.to_s
    @num = num
    @round = round
    @times = {}
  end

  def create_orders
    @orders = []

    price_and_volume = []
    (@num/2).times do
      price = 3000+rand(3000)
      volume = 1+rand(10)
      price_and_volume << [price, volume]
    end

    # Create asks and bids seperately, so asks will accumulate in memory before get matched
    price_and_volume.each do |(price, volume)|
      @orders << SweatFactory.make_ask_order(volume, price)
    end

    price_and_volume.each do |(price, volume)|
      @orders << SweatFactory.make_bid_order(volume, price)
    end
  end

  def matching_orders
    @results = []

    (@num/2).times do
      matching = Matching.new(:cnybtc)
      @results << matching.run(Trade.latest_price(:cnybtc))
    end
  end

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

    puts "\n>> Matching Orders"
    Benchmark.benchmark(Benchmark::CAPTION, 10, Benchmark::FORMAT) do |x|
      @times[:matching] = (1..@round).map do |i|
        x.report("Round #{i}") do
          matching_orders
        end
      end

      nil
    end

    avg = []
    File.open(Rails.root.join('tmp', "matching_result_#{@label}"), 'w') do |f|
      utime_avg = @times[:create].map(&:utime).sum / @round
      stime_avg = @times[:create].map(&:stime).sum / @round
      real_avg  = @times[:create].map(&:real).sum  / @round
      f.puts "#{utime_avg} #{stime_avg} #{real_avg}"
      avg << real_avg

      utime_avg = @times[:matching].map(&:utime).sum / @round
      stime_avg = @times[:matching].map(&:stime).sum / @round
      real_avg  = @times[:matching].map(&:real).sum  / @round
      f.puts "#{utime_avg} #{stime_avg} #{real_avg}"
      avg << real_avg
    end

    puts "\n>> Average throughput (orders per second)"
    puts "create: %.2fops matching: %.2fops" % [@num/avg[0], @num/avg[1]]
  end

end

if $0 == __FILE__
  raise "Must run in test environment!" unless Rails.env.test?

  label = ARGV[0] || Time.now.to_i
  num = ARGV[1] ? ARGV[1].to_i : 100
  round = ARGV[2] ? ARV[2].to_i : 3

  MatchingBenchmark.new(label, num, round).run
end
