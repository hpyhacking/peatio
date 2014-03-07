class OldMatching
  def initialize(currency)
    @currency = currency
  end

  attr_accessor :bid_price, :ask_price

  def run(latest_price)
    ActiveRecord::Base.transaction do
      bid = OrderBid.head(@currency).try(:lock!)
      ask = OrderAsk.head(@currency).try(:lock!)

      if bid and ask and bid.price >= ask.price
        lock_account(bid, ask)

        strike_volume = [bid.volume, ask.volume].min
        strike_price = strike_price(bid, ask, latest_price)
        trend = trend_state(strike_price, latest_price)

        trade = Trade.create(bid_id: bid.id, ask_id: ask.id,
                             price: strike_price, volume: strike_volume,
                             currency: @currency, trend: trend)

        bid.strike(trade)
        ask.strike(trade)

        trade
      else
        :idle
      end
    end
  end

  def trend_state(strike_price, latest_price)
    strike_price >= latest_price ? :up : :down
  end

  def strike_price(bid, ask, latest_price)
    if bid.price > ask.price
      scope = (ask.price..bid.price)
      if scope.include? latest_price
        latest_price
      elsif scope.min > latest_price
        scope.min
      elsif scope.max < latest_price
        scope.max
      end
    elsif bid.price == ask.price
      bid.price
    end
  end

  private

  def lock_account(bid, ask)
    bid.hold_account.lock!
    ask.hold_account.lock!
    bid.expect_account.lock!
    ask.expect_account.lock!
  end
end
