# == Schema Information
#
# Table name: trades
#
#  id            :integer          not null, primary key
#  price         :decimal(32, 16)
#  volume        :decimal(32, 16)
#  ask_id        :integer
#  bid_id        :integer
#  trend         :integer
#  currency      :integer
#  created_at    :datetime
#  updated_at    :datetime
#  ask_member_id :integer
#  bid_member_id :integer
#  funds         :decimal(32, 16)
#

class Trade < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  ZERO = '0.0'.to_d

  extend Enumerize
  enumerize :trend, in: {:up => 1, :down => 0}
  enumerize :currency, in: Market.enumerize, scope: true

  belongs_to :market, class_name: 'Market', foreign_key: 'currency'
  belongs_to :ask, class_name: 'OrderAsk', foreign_key: 'ask_id'
  belongs_to :bid, class_name: 'OrderBid', foreign_key: 'bid_id'

  belongs_to :ask_member, class_name: 'Member', foreign_key: 'ask_member_id'
  belongs_to :bid_member, class_name: 'Member', foreign_key: 'bid_member_id'

  validates_presence_of :price, :volume, :funds

  scope :h24, -> { where("created_at > ?", 24.hours.ago) }

  attr_accessor :side

  alias_method :sn, :id

  class << self
    def latest_price(currency)
      with_currency(currency).order(:id).reverse_order
        .limit(1).first.try(:price) || "0.0".to_d
    end

    def for_member(currency, member, options={})
      trades = with_currency(currency).where("ask_member_id = ? or bid_member_id = ?", member.id, member.id).order('id desc')
      trades = trades.where('created_at <= ?', options[:from]) if options[:from].present?
      trades = trades.limit(options[:limit]) if options[:limit].present?

      trades.each do |trade|
        trade.side = trade.ask_member_id == member.id ? 'ask' : 'bid'
      end
    end
  end

  def self_trade?
    ask_member_id == bid_member_id
  end

  def trigger_notify
    ask.member.notify 'trade', for_notify('ask')
    bid.member.notify 'trade', for_notify('bid')
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

  def for_global
    {
      tid:    id,
      type:   trend == 'down' ? 'sell' : 'buy',
      date:   created_at.to_i,
      price:  price.to_s || ZERO,
      amount: volume.to_s || ZERO
    }
  end
end
