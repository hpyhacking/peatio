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

    def make_ask_order(member, volume, price)
      make_order(OrderAsk, volume: volume, price: price, member: member)
    end

    def make_bid_order(member, volume, price)
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
    @times = {create_members: [], lock_funds: [], create_orders: [], matching: []}
  end

  def create_members
    @members = {ask: [], bid: []}

    (@num/2).times do
      @members[:ask] << SweatFactory.make_member
      @members[:bid] << SweatFactory.make_member
    end
  end

  def lock_funds
    @members[:ask].each do |m|
      m.get_account(:btc).update_attributes(locked: 100)
    end
    @members[:bid].each do |m|
      m.get_account(:cny).update_attributes(locked: 1000000)
    end
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
    @members[:ask].each_with_index do |m, i|
      price, volume = price_and_volume[i]
      @orders << SweatFactory.make_ask_order(m, volume, price)
    end
    @members[:bid].each_with_index do |m, i|
      price, volume = price_and_volume[i]
      @orders << SweatFactory.make_bid_order(m, volume, price)
    end
  end

  def matching_orders
    t1 = Trade.count

    @matches = 0
    matching = Matching.new(:cnybtc)
    loop do
      result = matching.run(Trade.latest_price(:cnybtc))
      @matches += 1
      raise StopIteration if result == :idle
    end

    @trades = Trade.count - t1
  end

  def run
    (1..@round).map do |i|
      puts "\n>> Round #{i}"
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        @times[:create_members] << x.report("create members") { create_members }
        @times[:lock_funds]     << x.report("lock funds") { lock_funds }
        @times[:create_orders]  << x.report("create orders") { create_orders }
        nil
      end
    end

    puts "\n>> Match Them All"
    Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
      t = x.report { matching_orders }
      @times[:matching] = [t]
      puts "#{@matches} matches run, #{@trades} trades created."
    end

    save
  end

  def save
    avg = {}

    File.open(Rails.root.join('tmp', "matching_result_#{@label}"), 'w') do |f|
      @times.each do |k, v|
        avg[k] = averages(v)
        f.puts avg[k].join(" ")
      end
    end

    puts "\n>> Average throughput (orders per second)"
    puts "create members: %.2fops" % [@num/avg[:create_members].last]
    puts "lock funds:     %.2fops" % [@num/avg[:lock_funds].last]
    puts "create orders:  %.2fops" % [@num/avg[:create_orders].last]
    puts "submit orders:  %.2fops" % [@num/(avg[:lock_funds].last+avg[:create_orders].last)]
    puts "matching:       %.2fops" % [@matches/avg[:matching].last]
    puts "* submit order = lock funds + create order"
  end

  def averages(times)
    utime_avg = times.map(&:utime).sum / times.size
    stime_avg = times.map(&:stime).sum / times.size
    real_avg  = times.map(&:real).sum  / times.size
    [utime_avg, stime_avg, real_avg]
  end
end

if $0 == __FILE__
  raise "Must run in test environment!" unless Rails.env.test?

  num = ARGV[0] ? ARGV[0].to_i : 250
  round = ARGV[1] ? ARGV[1].to_i : 4
  label = ARGV[2] || Time.now.to_i

  puts "\n>> Setup environment"
  system("rake db:reset")
  Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }

  MatchingBenchmark.new(label, num, round).run
end
