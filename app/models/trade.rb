# encoding: UTF-8
# frozen_string_literal: true

require 'peatio/influxdb'
class Trade < ApplicationRecord
  # == Constants ============================================================

  extend Enumerize
  ZERO = '0.0'.to_d

  # == Relationships ========================================================

  belongs_to :market, ->(trade) { where(type: trade.market_type) }, foreign_key: :market_id, primary_key: :symbol, required: true
  belongs_to :maker_order, class_name: 'Order', foreign_key: :maker_order_id, required: true
  belongs_to :taker_order, class_name: 'Order', foreign_key: :taker_order_id, required: true
  belongs_to :maker, class_name: 'Member', foreign_key: :maker_id, required: true
  belongs_to :taker, class_name: 'Member', foreign_key: :taker_id, required: true

  # == Validations ==========================================================

  validates :price, :amount, :total, numericality: { greater_than_or_equal_to: 0.to_d }

  validates :market_type,
            presence: true,
            inclusion: { in: Market::TYPES }

  # == Scopes ===============================================================

  scope :h24, -> { where('created_at > ?', 24.hours.ago) }
  scope :with_market, ->(market) { where(market_id: market) }
  scope :spot, -> { where(market_type: 'spot') }
  scope :qe, -> { where(market_type: 'qe') }

  # == Callbacks ============================================================

  after_validation(on: :create) do
    # Set taker type before creation
    self.taker_type = taker_order&.side
  end

  after_commit on: :create do
    EventAPI.notify ['market', market_id, 'trade_completed'].join('.'), \
      Serializers::EventAPI::TradeCompleted.call(self)
  end

  # == Class Methods ========================================================

  class << self
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

    def public_from_influx(market, limit = 100, options = {})
      trades_query = ['SELECT id, price, amount, total, taker_type, market, created_at FROM trades WHERE market=%{market}']
      trades_query << 'AND taker_type=%{type}' if options[:type].present?
      trades_query << 'AND created_at>=%{start_time}' if options[:start_time].present?
      trades_query << 'AND created_at<=%{end_time}' if options[:end_time].present?
      trades_query << 'AND price=%{price_eq}' if options[:price_eq].present?
      trades_query << 'AND price>=%{price_gt}' if options[:price_gt].present?
      trades_query << 'AND price=%{price_lt}' if options[:price_lt].present?
      trades_query << 'ORDER BY desc'

      unless limit.to_i.zero?
        trades_query << 'LIMIT %{limit}'
        options.merge!(limit: limit)
      end

      Peatio::InfluxDB.client(keyshard: market).query trades_query.join(' '), params: options.merge(market: market) do |_name, _tags, points|
        return points.map(&:deep_symbolize_keys!)
      end
    end

    # Low, High, First, Last, sum total (amount * price), sum 24 hours amount and average 24 hours price calculated using VWAP ratio for 24 hours trades
    def market_ticker_from_influx(market)
      tickers_query = 'SELECT MIN(price), MAX(price), FIRST(price), LAST(price), SUM(total) AS volume, SUM(amount) AS amount, SUM(total) / SUM(amount) AS vwap FROM trades WHERE market=%{market} AND time > now() - 24h'
      Peatio::InfluxDB.client(keyshard: market).query tickers_query, params: { market: market } do |_name, _tags, points|
        return points.map(&:deep_symbolize_keys!).first
      end
    end

    def trade_from_influx_before_date(market, date)
      trades_query = 'SELECT id, price, amount, total, taker_type, market, created_at FROM trades WHERE market=%{market} AND created_at < %{date} ORDER BY DESC LIMIT 1 '
      Peatio::InfluxDB.client(keyshard: market).query trades_query, params: { market: market, date: date.to_i } do |_name, _tags, points|
        return points.map(&:deep_symbolize_keys!).first
      end
    end

    def trade_from_influx_after_date(market, date)
      trades_query = 'SELECT id, price, amount, total, taker_type, market, created_at FROM trades WHERE market=%{market} AND created_at >= %{date} ORDER BY ASC LIMIT 1 '
      Peatio::InfluxDB.client(keyshard: market).query trades_query, params: { market: market, date: date.to_i } do |_name, _tags, points|
        return points.map(&:deep_symbolize_keys!).first
      end
    end

    def nearest_trade_from_influx(market, date)
      res = trade_from_influx_before_date(market, date)
      res.blank? ? trade_from_influx_after_date(market, date) : res
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

  def trigger_event
    ::AMQP::Queue.enqueue_event("private", maker.uid, "trade", for_notify(maker))
    ::AMQP::Queue.enqueue_event("private", taker.uid, "trade", for_notify(taker))
    ::AMQP::Queue.enqueue_event("public", market.symbol, "trades", {trades: [for_global]})
  end

  def for_notify(member = nil)
    { id:             id,
      price:          price.to_s  || ZERO,
      amount:         amount.to_s || ZERO,
      total:          total.to_s || ZERO,
      market:         market.symbol,
      side:           side(member),
      taker_type:     taker_type,
      created_at:     created_at.to_i,
      order_id:       order_for_member(member).id }
  end

  def for_global
    { tid:        id,
      taker_type: taker_type,
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

  def revert_trade!
    transaction do
      revert_sell_side!
      revert_buy_side!
      revert_fees!
    end
  end

  def influx_data
    { values:     { id:         id,
                    price:      price,
                    amount:     amount,
                    total:      total,
                    taker_type: taker_type,
                    created_at: created_at.to_i },
      tags:       { market: market.symbol } }
  end

  def write_to_influx
    Peatio::InfluxDB.client(keyshard: market_id).write_point(self.class.table_name, influx_data, "ns")
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

  def revert_sell_side!
    seller_outcome = amount
    seller_income = total - total * order_fee(sell_order)

    # Revert Trade for Sell side
    # Debit main fiat/crypto Liability account for member who created bid.
    Operations::Liability.debit!(
      amount: seller_income,
      currency: sell_order.income_currency,
      reference: self,
      kind: :main,
      member_id: sell_order.member_id
    )
    Account.find_by(currency_id: sell_order.income_currency.id, member_id: sell_order.member_id).sub_funds(seller_income)

    # Credit main fiat/crypto Liability account for member who created ask.
    Operations::Liability.credit!(
      amount: seller_outcome,
      currency: sell_order.outcome_currency,
      reference: self,
      kind: :main,
      member_id: sell_order.member_id
    )
    Account.find_by(currency_id: sell_order.outcome_currency.id, member_id: sell_order.member_id).plus_funds(seller_outcome)
  end

  def revert_buy_side!
    buyer_outcome = total
    buyer_income = amount - amount * order_fee(buy_order)

    # Revert Trade for Buy side
    # Debit main fiat/crypto Liability account for member who created ask
    Operations::Liability.debit!(
      amount: buyer_income,
      currency: buy_order.income_currency,
      reference: self,
      kind: :main,
      member_id: buy_order.member_id
    )
    Account.find_by(currency_id: buy_order.income_currency.id, member_id: buy_order.member_id).sub_funds(buyer_income)

    # Credit main fiat/crypto Liability account for member who created bid.
    Operations::Liability.credit!(
      amount: buyer_outcome,
      currency: buy_order.outcome_currency,
      reference: self,
      kind: :main,
      member_id: buy_order.member_id
    )
    Account.find_by(currency_id: buy_order.outcome_currency.id, member_id: buy_order.member_id).plus_funds(buyer_outcome)
  end

  def revert_fees!
    seller_fee = total * order_fee(sell_order)
    buyer_fee = amount * order_fee(buy_order)

    # Revert Revenues
    Operations::Revenue.debit!(
      amount:    seller_fee,
      currency:  sell_order.income_currency,
      reference: self,
      member_id: sell_order.member_id
    )

    Operations::Revenue.debit!(
      amount:    buyer_fee,
      currency:  buy_order.income_currency,
      reference: self,
      member_id: buy_order.member_id
    )
  end
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: trades
#
#  id             :bigint           not null, primary key
#  price          :decimal(32, 16)  not null
#  amount         :decimal(32, 16)  not null
#  total          :decimal(32, 16)  default(0.0), not null
#  maker_order_id :bigint           not null
#  taker_order_id :bigint           not null
#  market_id      :string(20)       not null
#  market_type    :string(255)      default("spot"), not null
#  maker_id       :bigint           not null
#  taker_id       :bigint           not null
#  taker_type     :string(20)       default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_trades_on_created_at                               (created_at)
#  index_trades_on_maker_id                                 (maker_id)
#  index_trades_on_maker_id_and_market_type                 (maker_id,market_type)
#  index_trades_on_maker_id_and_market_type_and_created_at  (maker_id,market_type,created_at)
#  index_trades_on_maker_order_id                           (maker_order_id)
#  index_trades_on_taker_id_and_market_type                 (taker_id,market_type)
#  index_trades_on_taker_order_id                           (taker_order_id)
#  index_trades_on_taker_type                               (taker_type)
#
