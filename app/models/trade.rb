class Trade < ActiveRecord::Base
  ZERO = '0.0'.to_d

  extend Enumerize
  enumerize :trend, in: {:up => 1, :down => 0}
  enumerize :currency, in: Market.enumerize, scope: true

  belongs_to :ask, class_name: 'OrderAsk', foreign_key: 'ask_id'
  belongs_to :bid, class_name: 'OrderBid', foreign_key: 'bid_id'

  scope :h24, -> { where("created_at > ?", 24.hours.ago) }
  scope :for_member, ->(currency, member) { with_currency(currency)
    .where("ask_member_id = ? or bid_member_id = ?", member.id, member.id) }

  class << self
    def latest_price(currency)
      with_currency(currency).order(:id).reverse_order
        .limit(1).first.try(:price) || "0.0".to_d
    end
  end

  def sn
    "##{id}"
  end

  def for_notify(kind="")
    {
      id:     id,
      kind:   kind,
      at:     created_at.to_i,
      price:  price.to_s  || ZERO,
      volume: volume.to_s || ZERO
    }
  end

  def notify
    ask.member.trigger 'trade', for_notify('ask')
    bid.member.trigger 'trade', for_notify('bid')
  end

end
