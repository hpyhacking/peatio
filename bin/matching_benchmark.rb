#!/usr/bin/env ruby

ENV['RAILS_ENV'] = 'test'

require 'benchmark'
require_relative '../config/environment'

Rails.logger = nil
ActiveRecord::Base.logger = nil
ActionController::Base.logger = nil
ActionView::Base.logger =  nil

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
    @times = Hash.new {|h,k| h[k] = [] }
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
    matches = 0
    instructions = []

    market = Market.find('cnybtc')
    engine = Matching::FIFOEngine.new(market)
    engine.define_singleton_method(:submit) do |order|
      orderbook.submit(order)
      while match?
        matches += 1
        instructions << trade
      end
    end

    @processed = Order.active.count
    Order.active.each do |order|
      engine.submit ::Matching::Order.new(order.to_matching_attributes)
    end

    @matches       = matches
    @instructions  = instructions
  end

  def execute_trades
    t1 = Trade.count

    market = Market.find('cnybtc')
    @instructions.each do |(ask, bid, strike_price, volume)|
      ::Matching::Executor.new(market, ask, bid, strike_price, volume).execute!
    end

    @trades = Trade.count - t1
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
