module Benchmark
  class Integration
    include Helpers

    def initialize(num)
      @num = num
    end

    def submit_orders
      puts "Submitting orders .."
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
        o = SweatFactory.make_order(OrderAsk, volume: volume, price: price, member: m)
        Ordering.new(o).submit
        @orders << o
      end
      @members[:bid].each_with_index do |m, i|
        price, volume = price_and_volume[i]
        o = SweatFactory.make_order(OrderBid, volume: volume, price: price, member: m)
        Ordering.new(o).submit
        @orders << o
      end
    end

    def run
      create_members
      deposit

      t1 = Time.now
      count = 0
      AMQPQueue.channel.queue('', auto_delete: true).bind(AMQPQueue.exchange(:trade_after_strike)).subscribe do |info, what, payload|
        t = Time.now - t1
        count += 1
        orate = @num.to_f/t
        trate = count.to_f/t
        print "\rTime elapsed: #{t}s   Orders: total #{@num}, rate #{orate}o/s   Trades: total #{count}, rate #{trate}t/s          "
      end

      submit_orders

      Signal.trap("INT") do
        AMQPQueue.channel.work_pool.kill
        puts "\nFinished."
      end
      AMQPQueue.channel.work_pool.join
    end

  end
end
