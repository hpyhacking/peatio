class OrderBid < Order

  has_many :trades, foreign_key: 'bid_id'

  scope :matching_rule, -> { order('price DESC, created_at ASC') }

  def get_account_changes(trade)
    [trade.funds, trade.volume]
  end

  def hold_account
    currency = Currency.find(bid)
    member.get_account(currency.code)
  end

  def expect_account
    currency = Currency.find(ask)
    member.get_account(currency.code)
  end

  def avg_price
    return ::Trade::ZERO if funds_received.zero?
    config.fix_number_precision(:bid, funds_used / funds_received)
  end

  LOCKING_BUFFER_FACTOR = '1.1'.to_d
  def compute_locked
    case ord_type
    when 'limit'
      price*volume
    when 'market'
      funds = estimate_required_funds(Global[market_id].asks) {|p, v| p*v }
      funds*LOCKING_BUFFER_FACTOR
    end
  end

end

# == Schema Information
# Schema version: 20180417175453
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  bid            :integer
#  ask            :integer
#  market_id      :string(10)
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)
#  origin_volume  :decimal(32, 16)
#  fee            :decimal(32, 16)  default(0.0), not null
#  state          :integer
#  done_at        :datetime
#  type           :string(8)
#  member_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  sn             :string(255)
#  source         :string           not null
#  ord_type       :string
#  locked         :decimal(32, 16)
#  origin_locked  :decimal(32, 16)
#  funds_received :decimal(32, 16)  default(0.0)
#  trades_count   :integer          default(0)
#
# Indexes
#
#  index_orders_on_market_id_and_state  (market_id,state)
#  index_orders_on_member_id            (member_id)
#  index_orders_on_member_id_and_state  (member_id,state)
#  index_orders_on_state                (state)
#
