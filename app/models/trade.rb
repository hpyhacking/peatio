# encoding: UTF-8
# frozen_string_literal: true

class Trade < ApplicationRecord
  include BelongsToMarket
  extend Enumerize
  ZERO = '0.0'.to_d

  enumerize :trend, in: { up: 1, down: 0 }

  belongs_to :ask, class_name: 'OrderAsk', foreign_key: :ask_id, required: true
  belongs_to :bid, class_name: 'OrderBid', foreign_key: :bid_id, required: true
  belongs_to :ask_member, class_name: 'Member', foreign_key: :ask_member_id, required: true
  belongs_to :bid_member, class_name: 'Member', foreign_key: :bid_member_id, required: true

  validates :price, :volume, :funds, numericality: { greater_than_or_equal_to: 0.to_d }

  scope :h24, -> { where('created_at > ?', 24.hours.ago) }

  after_commit on: :create do
    EventAPI.notify ['market', market_id, 'trade_completed'].join('.'), \
      Serializers::EventAPI::TradeCompleted.call(self)
  end


  class << self
    def latest_price(market)
      trade = with_market(market).order(id: :desc).limit(1).first
      trade ? trade.price : 0
    end
  end

  def side(member)
    return unless member

    self.ask_member_id == member.id ? 'ask' : 'bid'
  end

  def for_notify(member = nil)
    { id:     id,
      kind:   side(member),
      at:     created_at.to_i,
      price:  price.to_s  || ZERO,
      volume: volume.to_s || ZERO,
      ask_id: ask_id,
      bid_id: bid_id,
      market: market.id }
  end

  def for_global
    { tid:        id,
      taker_type: ask_id > bid_id ? :sell : :buy,
      date:       created_at.to_i,
      price:      price.to_s || ZERO,
      amount:     volume.to_s || ZERO }
  end

  def record_complete_operations!
    transaction do
      record_liability_debit!
      record_liability_credit!
      record_liability_transfer!
      record_revenues!
    end
  end

  private
  def record_liability_debit!
    ask_currency_outcome = volume
    bid_currency_outcome = funds

    # Debit locked fiat/crypto Liability account for member who created ask.
    Operations::Liability.debit!(
      amount:    ask_currency_outcome,
      currency:  ask.currency,
      reference: self,
      kind:      :locked,
      member_id: ask.member_id,
    )
    # Debit locked fiat/crypto Liability account for member who created bid.
    Operations::Liability.debit!(
      amount:    bid_currency_outcome,
      currency:  bid.currency,
      reference: self,
      kind:      :locked,
      member_id: bid.member_id,
    )
  end

  def record_liability_credit!
    # We multiply ask outcome by bid fee.
    # Fees are related to side bid or ask (not currency).
    ask_currency_income = volume - volume * bid.fee
    bid_currency_income = funds - funds * ask.fee

    # Credit main fiat/crypto Liability account for member who created ask.
    Operations::Liability.credit!(
      amount:    bid_currency_income,
      currency:  bid.currency,
      reference: self,
      kind:      :main,
      member_id: ask.member_id
    )

    # Credit main fiat/crypto Liability account for member who created bid.
    Operations::Liability.credit!(
      amount:    ask_currency_income,
      currency:  ask.currency,
      reference: self,
      kind:      :main,
      member_id: bid.member_id
    )
  end

  def record_liability_transfer!
    # Unlock unused funds.
    [bid, ask].each do |order|
      if order.volume.zero? && !order.locked.zero?
        Operations::Liability.transfer!(
          amount:    order.locked,
          currency:  order.currency,
          reference: self,
          from_kind: :locked,
          to_kind:   :main,
          member_id: order.member_id
        )
      end
    end
  end

  def record_revenues!
    ask_currency_fee = volume * bid.fee
    bid_currency_fee = funds * ask.fee

    # Credit main fiat/crypto Revenue account.
    Operations::Revenue.credit!(
      amount:    ask_currency_fee,
      currency:  ask.currency,
      reference: self,
      member_id: bid.member_id
    )

    # Credit main fiat/crypto Revenue account.
    Operations::Revenue.credit!(
      amount:    bid_currency_fee,
      currency:  bid.currency,
      reference: self,
      member_id: ask.member_id
    )
  end
end

# == Schema Information
# Schema version: 20190213104708
#
# Table name: trades
#
#  id            :integer          not null, primary key
#  price         :decimal(32, 16)  not null
#  volume        :decimal(32, 16)  not null
#  ask_id        :integer          not null
#  bid_id        :integer          not null
#  trend         :integer          not null
#  market_id     :string(20)       not null
#  ask_member_id :integer          not null
#  bid_member_id :integer          not null
#  funds         :decimal(32, 16)  not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trades_on_ask_id                           (ask_id)
#  index_trades_on_ask_member_id_and_bid_member_id  (ask_member_id,bid_member_id)
#  index_trades_on_bid_id                           (bid_id)
#  index_trades_on_created_at                       (created_at)
#  index_trades_on_market_id_and_created_at         (market_id,created_at)
#
