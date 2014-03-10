namespace :perf do

  desc "Order matching performance tests"
  task :matching => :environment do
    raise "This task must be run in test environment: RAILS_ENV=test" unless Rails.env.test?

    num   = ENV['NUM'] || 100
    round = ENV['ROUND'] || 3
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
