class OrderAsk < Order

  has_many :trades, foreign_key: 'ask_id'

  scope :matching_rule, -> { order('price ASC, created_at ASC') }

  def get_account_changes(trade)
    [trade.volume, trade.funds]
  end

  def hold_account
    member.get_account(ask)
  end

  def expect_account
    member.get_account(bid)
  end

  def sum(v = nil, p = nil)
    v ||= volume
  end

  def hold_account_attr
    :origin_volume
  end

  def compute_locked
    volume
  end

end
