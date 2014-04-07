class Trade < ActiveRecord::Base
  ZERO = '0.0'.to_d

  extend Enumerize
  enumerize :trend, in: {:up => 1, :down => 0}
  enumerize :currency, in: Market.enumerize, scope: true

  belongs_to :ask, class_name: 'OrderAsk', foreign_key: 'ask_id'
  belongs_to :bid, class_name: 'OrderBid', foreign_key: 'bid_id'

  belongs_to :ask_member, class_name: 'Member', foreign_key: 'ask_member_id'
  belongs_to :bid_member, class_name: 'Member', foreign_key: 'bid_member_id'

  scope :h24, -> { where("created_at > ?", 24.hours.ago) }

  class << self
    def latest_price(currency)
      with_currency(currency).order(:id).reverse_order
        .limit(1).first.try(:price) || "0.0".to_d
    end

    def for_member(currency, member)
      trades = with_currency(currency).where("ask_member_id = ? or bid_member_id = ?", member.id, member.id)

      trades.each do |trade|
        trade.side = trade.ask_member_id == member.id ? 'ask' : 'bid'
      end
    end
  end

  attr_accessor :side

  def sn
    "##{id}"
  end

  def for_notify(kind=nil)
    {
      id:     id,
      kind:   kind || side,
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
