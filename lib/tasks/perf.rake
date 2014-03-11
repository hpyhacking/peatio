require_relative '../../spec/support/matching_helper'

namespace :perf do

  namespace :order do
    desc "Order create performance"
    task :create => :environment do
      raise "This task must be run in test environment: RAILS_ENV=test" unless Rails.env.test?

      num   = ENV['NUM'] ? ENV['NUM'].to_i : 100
      round = ENV['ROUND'] ? ENV['ROUND'].to_i : 3
      results = []

      puts "Matching Performance Test (#{round} rounds, #{num} full match orders per round)\n"
      member = make_member
      volume = '1.0'.to_d
      price  = '3000.45'.to_d
      order_class = [OrderAsk, OrderBid]

      round.times do |i|
        puts "Round #{i+1} >>\n"
        t = Benchmark.realtime do
          num.times do
            klass = order_class.sample
            make_order(klass, member: member, volume: volume, price: price)
          end
        end
        results << [num, t]
        puts "#{num} orders created in #{t} seconds."
      end

      total_num = results.map(&:first).sum
      total_t   = results.map(&:last).sum
      puts "Average order creation rate: #{total_num/total_t} orders/s"
    end
  end

  namespace :matching do
    desc "In-memory matching engine performance"
    task :engine => :environment do
      raise "This task must be run in test environment: RAILS_ENV=test" unless Rails.env.test?

      num   = ENV['NUM'] ? ENV['NUM'].to_i : 10000
      round = ENV['ROUND'] ? ENV['ROUND'].to_i : 5
      results = []

      puts "Matching Performance Test (#{round} rounds, #{num} full match orders per round)\n"

      round.times do |i|
        puts "Round #{i+1} >>\n"

        orders = []
        price_and_volume = []
        t = Benchmark.realtime do
          (num/2).times do
            price = 3000+rand(3000)
            volume = 1+rand(10)
            price_and_volume << [price, volume]
          end

          # Create asks and bids seperately, so asks will accumulate in memory before get matched
          price_and_volume.each do |(price, volume)|
            orders << Matching.mock_order(type: :ask, volume: volume, price: price)
          end

          price_and_volume.each do |(price, volume)|
            orders << Matching.mock_order(type: :bid, volume: volume, price: price)
          end
        end

        puts "#{num} orders created in #{t} seconds."

        market = Market.find('cnybtc')
        engine = Matching::FIFOEngine.new(market)
        engine.define_singleton_method(:submit) do |order|
          orderbook.submit(order)
          trade while match?
        end

        t = Benchmark.realtime do
          orders.each do |order|
            engine.submit order
          end
        end

        puts "#{num} orders processed in #{t} seconds = #{'%.2f' % (num/t)} orders/sec"

        results << [num, t]
      end

      total_num = results.map(&:first).sum
      total_t   = results.map(&:last).sum
      puts "Average throughput: #{total_num/total_t} orders/sec"
    end

    desc "Performance of a complete matching cycle, including in-memory matching and write back database"
    task :complete => :environment do
      raise "This task must be run in test environment: RAILS_ENV=test" unless Rails.env.test?

      num   = ENV['NUM'] ? ENV['NUM'].to_i : 100
      round = ENV['ROUND'] ? ENV['ROUND'].to_i : 3
      results = []

      puts "Matching Performance Test (#{round} rounds, #{num} full match orders per round)\n"

      round.times do |i|
        puts "Round #{i+1} >>\n"

        ::Order.delete_all
        ::Trade.delete_all
        ::Member.delete_all

        t = Benchmark.realtime do
          (num/2).times do
            make_ask_order('10.0'.to_d, '1.0'.to_d)
            make_bid_order('10.0'.to_d, '1.0'.to_d)
          end
        end

        puts "#{num} orders created in #{t} seconds."

        t = Benchmark.realtime do
          Order.order('id asc').each do |order|
            ::Job::Matching.perform order.to_matching_attributes
          end
        end

        puts "#{Trade.count} trades created."
        puts "#{num} orders processed in #{t} seconds = #{'%.2f' % (num/t)} orders/sec"

        results << [num, t]
      end

      total_num = results.map(&:first).sum
      total_t   = results.map(&:last).sum
      puts "Average throughput: #{total_num/total_t} orders/sec"
    end
  end

  @seq = 0
  def make_member
    @seq += 1
    member = Member.create!(
      email: "user#{@seq}@example.com",
      name: "user-matching-perf-#{@seq}"
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
