# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  bid           :integer
#  ask           :integer
#  currency      :integer
#  price         :decimal(32, 16)
#  volume        :decimal(32, 16)
#  origin_volume :decimal(32, 16)
#  state         :integer
#  done_at       :datetime
#  type          :string(8)
#  member_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  sn            :string(255)
#  source        :string(255)      not null
#  ord_type      :string(10)
#  locked        :decimal(32, 16)
#  origin_locked :decimal(32, 16)
#

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

  def avg_price
    return ::Trade::ZERO if funds_received.zero?
    funds_used / funds_received
  end

  LOCKING_BUFFER_FACTOR = '1.1'.to_d
  def compute_locked
    case ord_type
    when 'limit'
      price*volume
    when 'market'
      funds = estimate_required_funds(Global[currency].asks) {|p, v| p*v }
      funds*LOCKING_BUFFER_FACTOR
    end
  end

end
