class Trade < ActiveRecord::Base
  ZERO = '0.0'.to_d

  extend Enumerize
  enumerize :trend, in: {:up => 1, :down => 0}

  belongs_to :market, class_name: 'Market'
  belongs_to :ask, class_name: 'OrderAsk', foreign_key: 'ask_id'
  belongs_to :bid, class_name: 'OrderBid', foreign_key: 'bid_id'

  belongs_to :ask_member, class_name: 'Member', foreign_key: 'ask_member_id'
  belongs_to :bid_member, class_name: 'Member', foreign_key: 'bid_member_id'

  validates_presence_of :price, :volume, :funds

  scope :h24, -> { where("created_at > ?", 24.hours.ago) }

  attr_accessor :side

  alias_method :sn, :id

  scope :with_market, -> (market) { where(market: Market === market ? market : Market.find(market)) }

  class << self
    def latest_price(market)
      with_market(market).order(:id).reverse_order
        .limit(1).first.try(:price) || "0.0".to_d
    end

    def filter(market, timestamp, from, to, limit, order)
      trades = with_market(market).order(order)
      trades = trades.limit(limit) if limit.present?
      trades = trades.where('created_at <= ?', timestamp) if timestamp.present?
      trades = trades.where('id > ?', from) if from.present?
      trades = trades.where('id < ?', to) if to.present?
      trades
    end

    def for_member(currency, member, options={})
      trades = filter(currency, options[:time_to], options[:from], options[:to], options[:limit], options[:order]).where("ask_member_id = ? or bid_member_id = ?", member.id, member.id)
      trades.each do |trade|
        trade.side = trade.ask_member_id == member.id ? 'ask' : 'bid'
      end
    end
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
      volume: volume.to_s || ZERO,
      market: market
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

# == Schema Information
# Schema version: 20180329154130
#
# Table name: trades
#
#  id            :integer          not null, primary key
#  price         :decimal(32, 16)
#  volume        :decimal(32, 16)
#  ask_id        :integer
#  bid_id        :integer
#  trend         :integer
#  market_id     :string(10)
#  created_at    :datetime
#  updated_at    :datetime
#  ask_member_id :integer
#  bid_member_id :integer
#  funds         :decimal(32, 16)
#
# Indexes
#
#  index_trades_on_ask_id         (ask_id)
#  index_trades_on_ask_member_id  (ask_member_id)
#  index_trades_on_bid_id         (bid_id)
#  index_trades_on_bid_member_id  (bid_member_id)
#  index_trades_on_created_at     (created_at)
#  index_trades_on_market_id      (market_id)
#
