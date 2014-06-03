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

  LOCKING_BUFFER_FACTOR = '1.1'.to_d
  def compute_locked
    case ord_type
    when 'limit'
      price*volume
    when 'market'
      funds = estimate_required_funds(Global[currency].asks) {|p, v| p.mult_and_round(v) }
      funds.mult_and_round(LOCKING_BUFFER_FACTOR)
    end
  end

end
