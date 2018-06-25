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
        m.get_account(SweatFactory.coin_currency.code).update!(locked: 100)
      end
      @members[:bid].each do |m|
        m.get_account(SweatFactory.fiat_currency.code).update!(locked: 1000000)
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
        o.fix_number_precision # number must be fixed before computing locked
        o.locked = o.origin_locked = o.compute_locked
        o.save!
        @orders << o
      end
      @members[:bid].each_with_index do |m, i|
        price, volume = price_and_volume[i]
        o = SweatFactory.make_order(OrderBid, volume: volume, price: price, member: m)
        o.fix_number_precision # number must be fixed before computing locked
        o.locked = o.origin_locked = o.compute_locked
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

      @instructions.each_with_index do |payload, i|
        unless Process.fork
          ActiveRecord::Base.connection.reconnect!
          puts "Executor #{i+1} started."

          t1 = Time.now
          ::Matching::Executor.new(payload).execute!

          puts "Executor #{i+1} finished work, stop."
          exit 0
        end
      end
      pid_and_status = Process.waitall

      ActiveRecord::Base.connection.reconnect!
      @trades = Trade.count - t1
    end



  end
end
