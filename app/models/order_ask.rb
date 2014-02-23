class OrderAsk < Order
  def kind
    "ask"
  end

  def opposite_kind
    "bid"
  end

  def sum(v = nil, p = nil)
    v ||= volume
  end

  def self.strike_sum(volume, price)
    [volume, volume * price]
  end

  def hold_account_attr
    :origin_volume
  end

  has_many :trades, foreign_key: 'ask_id'

  scope :matching_rule, -> { order('price ASC, created_at ASC') }
end
