class Trade < ActiveRecord::Base
  extend Enumerize
  enumerize :trend, in: {:up => 1, :down => 0}
  enumerize :currency, in: Market.enumerize, scope: true

  after_create :link_member
  has_and_belongs_to_many :members

  belongs_to :ask, class_name: 'OrderAsk', foreign_key: 'ask_id'
  belongs_to :bid, class_name: 'OrderBid', foreign_key: 'bid_id'

  scope :h24, -> { where("created_at > ?", 24.hours.ago) }

  def sn
    "##{id}"
  end

  def self.latest_price(currency)
    with_currency(currency).last.try(:price) || "0.0".to_d
  end

  attr_accessor :order

  private

  def link_member
    self.bid && self.bid.member.trades << self
    self.bid && self.ask.member.trades << self
  end
end
