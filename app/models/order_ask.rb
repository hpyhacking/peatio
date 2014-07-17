# == Schema Information
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  bid            :integer
#  ask            :integer
#  currency       :integer
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)
#  origin_volume  :decimal(32, 16)
#  state          :integer
#  done_at        :datetime
#  type           :string(8)
#  member_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  sn             :string(255)
#  source         :string(255)      not null
#  ord_type       :string(10)
#  locked         :decimal(32, 16)
#  origin_locked  :decimal(32, 16)
#  funds_received :decimal(32, 16)  default(0.0)
#

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

  def avg_price
    return ::Trade::ZERO if funds_used.zero?
    funds_received / funds_used
  end

  def compute_locked
    case ord_type
    when 'limit'
      volume
    when 'market'
      estimate_required_funds(Global[currency].bids) {|p, v| v}
    end
  end

end
