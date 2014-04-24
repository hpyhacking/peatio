module Benchmark
  module Helpers

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
        o = SweatFactory.make_order(OrderAsk, volume: volume, price: price, member: m)
        o.save!
        @orders << o
      end
      @members[:bid].each_with_index do |m, i|
        price, volume = price_and_volume[i]
        o = SweatFactory.make_order(OrderBid, volume: volume, price: price, member: m)
        o.save!
        @orders << o
      end
    end

    def matching_orders
      matches = 0
      instructions = []

      worker = Worker::Matching.new

      @processed = Order.active.count
      Order.active.each do |order|
        worker.process({action: 'submit', order: order.to_matching_attributes}, {}, {})
      end

      @instructions = AMQPQueue.queues[:trade_executor]
      @matches      = @instructions.size
    end

    def execute_trades
      t1 = Trade.count

      @instructions.each do |payload|
        ::Matching::Executor.new(payload).execute!
      end

      @trades = Trade.count - t1
    end

  end
end
