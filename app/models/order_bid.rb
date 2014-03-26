class OrderBid < Order

  def hold_account
    member.get_account(bid)
  end

  def expect_account
    member.get_account(ask)
  end

  def kind
    "bid"
  end

  def opposite_kind
    "ask"
  end

  def sum(v = nil, p = nil)
    p ||= self.price
    v ||= self.volume
    (v * p) if (v && p)
  end

  def self.strike_sum(volume, price)
    [volume * price, volume]
  end

  def hold_account_attr
    :sum
  end

  has_many :trades, foreign_key: 'bid_id'

  scope :matching_rule, -> { order('price DESC, created_at ASC') }
end
