module Worker
  class TradeStats < Stats

    def initialize(market)
      super()
      @market = market
    end

    def to_s
      "#{self.class.name} (#{@market.id})"
    end

    def key_for(period)
      "peatio:stats:trades:#{@market.id}:#{period}"
    end

    def point_1(from)
      to = from + 1.minute
      trades = Trade.with_currency(@market.id).where(created_at: from...to).pluck(:ask_member_id, :bid_member_id)
      trade_users = trades.flatten.uniq
      [from.to_i, trades.size, trade_users.size]
    end

    def point_n(from, period)
      arr = point_1_set from, period
      trades_count = arr.sum {|point| point[1]}
      trade_users_count = arr.sum(&:last)
      [from.to_i, trades_count, trade_users_count]
    end

  end
end
