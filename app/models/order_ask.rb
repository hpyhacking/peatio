class OrderAsk < Order

  has_many :trades, foreign_key: 'ask_id'

  scope :matching_rule, -> { order('price ASC, created_at ASC') }

  def self.strike_sum(volume, price)
    [volume, volume * price]
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

end
