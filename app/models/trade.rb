# encoding: UTF-8
# frozen_string_literal: true

class Trade < ApplicationRecord
  # == Constants ============================================================

  include BelongsToMarket
  extend Enumerize
  ZERO = '0.0'.to_d

  # == Relationships ========================================================

  belongs_to :maker_order, class_name: 'Order', foreign_key: :maker_order_id, required: true
  belongs_to :taker_order, class_name: 'Order', foreign_key: :taker_order_id, required: true
  belongs_to :maker, class_name: 'Member', foreign_key: :maker_id, required: true
  belongs_to :taker, class_name: 'Member', foreign_key: :taker_id, required: true

  # == Validations ==========================================================

  validates :price, :amount, :total, numericality: { greater_than_or_equal_to: 0.to_d }

  # == Scopes ===============================================================

  scope :h24, -> { where('created_at > ?', 24.hours.ago) }

  # == Callbacks ============================================================

  after_commit on: :create do
    EventAPI.notify ['market', market_id, 'trade_completed'].join('.'), \
      Serializers::EventAPI::TradeCompleted.call(self)
  end

  # == Class Methods ========================================================

  class << self
    def latest_price(market)
      trade = with_market(market).order(id: :desc).limit(1).first
      trade ? trade.price : 0
    end

    def to_csv
      attributes = %w[id price amount maker_order_id taker_order_id market_id maker_id taker_id total created_at updated_at]
      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |trade|
          data = attributes[0...-2].map { |attr| trade.send(attr) }
          data += attributes[-2..-1].map { |attr| trade.send(attr).iso8601 }
          csv << data
        end
      end
    end
  end

  # == Instance Methods =====================================================

  def order_fee(order)
    maker_order_id == order.id ? order.maker_fee : order.taker_fee
  end

  def side(member)
    return unless member

    order_for_member(member).side
  end

  def order_for_member(member)
    return unless member

    if member.id == maker_id
      maker_order
    elsif member.id == taker_id
      taker_order
    end
  end

  def sell_order
    [maker_order, taker_order].find { |o| o.side == 'sell' }
  end

  def buy_order
    [maker_order, taker_order].find { |o| o.side == 'buy' }
  end

  def for_notify(member = nil)
    { id:             id,
      price:          price.to_s  || ZERO,
      amount:         amount.to_s || ZERO,
      total:          total.to_s || ZERO,
      market:         market.id,
      side:           side(member),
      taker_type:     taker_order.side,
      created_at:     created_at.to_i,
      order_id:       order_for_member(member).id }
  end

  def for_global
    { tid:        id,
      taker_type: taker_order.side,
      date:       created_at.to_i,
      price:      price.to_s || ZERO,
      amount:     amount.to_s || ZERO }
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
    seller_outcome = amount
    buyer_outcome = total

    # Debit locked fiat/crypto Liability account for member who created ask.
    Operations::Liability.debit!(
      amount:    seller_outcome,
      currency:  sell_order.outcome_currency,
      reference: self,
      kind:      :locked,
      member_id: sell_order.member_id,
    )
    # Debit locked fiat/crypto Liability account for member who created bid.
    Operations::Liability.debit!(
      amount:    buyer_outcome,
      currency:  buy_order.outcome_currency,
      reference: self,
      kind:      :locked,
      member_id: buy_order.member_id,
    )
  end

  def record_liability_credit!
    seller_income = total - total * order_fee(sell_order)
    buyer_income = amount - amount * order_fee(buy_order)

    # Credit main fiat/crypto Liability account for member who created ask.
    Operations::Liability.credit!(
      amount:    buyer_income,
      currency:  buy_order.income_currency,
      reference: self,
      kind:      :main,
      member_id: buy_order.member_id
    )

    # Credit main fiat/crypto Liability account for member who created bid.
    Operations::Liability.credit!(
      amount:    seller_income,
      currency:  sell_order.income_currency,
      reference: self,
      kind:      :main,
      member_id: sell_order.member_id
    )
  end

  def record_liability_transfer!
    # Unlock unused funds.
    [maker_order, taker_order].each do |order|
      if order.volume.zero? && !order.locked.zero?
        Operations::Liability.transfer!(
          amount:    order.locked,
          currency:  order.outcome_currency,
          reference: self,
          from_kind: :locked,
          to_kind:   :main,
          member_id: order.member_id
        )
      end
    end
  end

  def record_revenues!
    seller_fee = total * order_fee(sell_order)
    buyer_fee = amount * order_fee(buy_order)

    # Credit main fiat/crypto Revenue account.
    Operations::Revenue.credit!(
      amount:    seller_fee,
      currency:  sell_order.income_currency,
      reference: self,
      member_id: sell_order.member_id
    )

    # Credit main fiat/crypto Revenue account.
    Operations::Revenue.credit!(
      amount:    buyer_fee,
      currency:  buy_order.income_currency,
      reference: self,
      member_id: buy_order.member_id
    )
  end
end

# == Schema Information
# Schema version: 20190813121822
#
# Table name: trades
#
#  id             :integer          not null, primary key
#  price          :decimal(32, 16)  not null
#  amount         :decimal(32, 16)  not null
#  total          :decimal(32, 16)  default(0.0), not null
#  maker_order_id :integer          not null
#  taker_order_id :integer          not null
#  market_id      :string(20)       not null
#  maker_id       :integer          not null
#  taker_id       :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_trades_on_created_at                (created_at)
#  index_trades_on_maker_id_and_taker_id     (maker_id,taker_id)
#  index_trades_on_maker_order_id            (maker_order_id)
#  index_trades_on_market_id_and_created_at  (market_id,created_at)
#  index_trades_on_taker_order_id            (taker_order_id)
#
