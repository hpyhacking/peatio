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

  def compute_locked
    case ord_type
    when 'limit'
      price*volume
    when 'market'
      '100'.to_d # TODO: replace stub
    end
  end

end
