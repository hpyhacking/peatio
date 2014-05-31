class OrderBid < Order

  has_many :trades, foreign_key: 'bid_id'

  scope :matching_rule, -> { order('price DESC, created_at ASC') }

  def get_account_changes(trade)
    [trade.funds, trade.volume]
  end

  def hold_account
    member.get_account(bid)
  end

  def expect_account
    member.get_account(ask)
  end

  def sum(v = nil, p = nil)
    p ||= self.price
    v ||= self.volume
    (v * p) if (v && p)
  end

  def hold_account_attr
    :sum
  end

  LOCKING_BUFFER_FACTOR = '1.1'.to_d
  def compute_locked
    case ord_type
    when 'limit'
      price*volume
    when 'market'
      estimate_required_funds.mult_and_round(LOCKING_BUFFER_FACTOR)
    end
  end

  def estimate_required_funds
    required_funds = Account::ZERO
    expected_volume = volume

    price_levels = Global[currency].asks

    until expected_volume.zero? || price_levels.empty?
      level_price, level_volume = price_levels.shift
      v = [expected_volume, level_volume].min
      required_funds += level_price.mult_and_round(v)
      expected_volume -= v
    end

    raise "Market is not deep enough" unless expected_volume.zero?

    required_funds
  end

end
