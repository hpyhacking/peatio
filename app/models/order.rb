# encoding: UTF-8
# frozen_string_literal: true

require 'csv'

class Order < ApplicationRecord

  belongs_to :market, ->(order) { where(type: order.market_type) }, foreign_key: :market_id, primary_key: :symbol, required: true
  belongs_to :member, required: true
  attribute :uuid, :uuid if Rails.configuration.database_adapter.downcase != 'PostgreSQL'.downcase

  # Error is raised in case market doesn't have enough volume to fulfill the Order.
  InsufficientMarketLiquidity = Class.new(StandardError)

  extend Enumerize
  STATES = { pending: 0, wait: 100, done: 200, cancel: -100, reject: -200 }.freeze
  enumerize :state, in: STATES, scope: true

  TYPES = %w[market limit].freeze

  THIRD_PARTY_ORDER_ACTION_TYPE = {
    'submit_single' => 0,
    'cancel_single' => 3,
    'cancel_bulk' => 4
  }.freeze

  belongs_to :ask_currency, class_name: 'Currency', foreign_key: :ask
  belongs_to :bid_currency, class_name: 'Currency', foreign_key: :bid
  after_commit :trigger_event

  validates :market_type, presence: true, inclusion: { in: ->(_o) { Market::TYPES } }

  validates :ord_type, :volume, :origin_volume, :locked, :origin_locked, presence: true
  validates :price, numericality: { greater_than: 0 }, if: ->(order) { order.ord_type == 'limit' }

  validates :origin_volume,
            numericality: { greater_than: 0, greater_than_or_equal_to: ->(order){ order.market.min_amount } },
            on: :create

  validates :origin_volume, precision: { less_than_or_eq_to: ->(o) { o.market.amount_precision } },
                            if: ->(o) { o.origin_volume.present? }, on: :create

  validate  :market_order_validations, if: ->(order) { order.ord_type == 'market' }

  validates :price, presence: true, if: :is_limit_order?

  validates :price, precision: { less_than_or_eq_to: ->(o) { o.market.price_precision } },
                    if: ->(o) { o.price.present? }, on: :create

  validates :price,
            numericality: { less_than_or_equal_to: ->(order){ order.market.max_price }},
            if: ->(order) { order.is_limit_order? && order.market.max_price.nonzero? },
            on: :create

  validates :price,
            numericality: { greater_than_or_equal_to: ->(order){ order.market.min_price }},
            if: :is_limit_order?, on: :create

  attr_readonly :member_id,
                :bid,
                :ask,
                :market_id,
                :ord_type,
                :origin_volume,
                :origin_locked,
                :created_at

  PENDING = 'pending'
  WAIT    = 'wait'
  DONE    = 'done'
  CANCEL  = 'cancel'
  REJECT  = 'reject'

  scope :done, -> { with_state(:done) }
  scope :active, -> { with_state(:wait) }
  scope :with_market, ->(market) { where(market_id: market) }
  scope :spot, -> { where(market_type: 'spot') }
  scope :qe, -> { where(market_type: 'qe') }

  # Custom ransackers.

  ransacker :state, formatter: proc { |v| STATES[v.to_sym] } do |parent|
    parent.table[:state]
  end

  # Single Order can produce multiple Trades with different fee types (maker and taker).
  # Since we can't predict fee types on order creation step and
  # Market fees configuration can change we need to store fees on Order creation.
  after_validation(on: :create, if: ->(o) { o.errors.blank? }) do
    trading_fee = TradingFee.for(group: member.group, market_id: market_id, market_type: market_type)
    self.maker_fee = trading_fee.maker
    self.taker_fee = trading_fee.taker
  end

  before_create do
    self.uuid = UUID.generate if uuid.blank?
  end

  after_commit on: :create do
    next unless ord_type == 'limit'
    EventAPI.notify ['market', market_id, 'order_created'].join('.'), \
      Serializers::EventAPI::OrderCreated.call(self)
  end

  after_commit on: :update do
    next unless ord_type == 'limit'

    event = case state
      when 'cancel' then 'order_canceled'
      when 'done'   then 'order_completed'
      else 'order_updated'
    end

    Serializers::EventAPI.const_get(event.camelize).call(self).tap do |payload|
      EventAPI.notify ['market', market_id, event].join('.'), payload
    end
  end

  class << self
    def submit(id)
      ActiveRecord::Base.transaction do
        order = lock.find_by_id!(id)
        return unless order.state == ::Order::PENDING

        order.hold_account!.lock_funds!(order.locked)
        order.record_submit_operations!
        order.update!(state: ::Order::WAIT)

        AMQP::Queue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
      end
    rescue => e
      order = find_by_id!(id)
      order.update!(state: ::Order::REJECT) if order

      raise e
    end

    def cancel(id)
      order = lock.find_by_id!(id)
      market_engine = order.market.engine
      return unless order.state == ::Order::WAIT

      return order.trigger_third_party_cancellation unless market_engine.peatio_engine?

      ActiveRecord::Base.transaction do
        order.hold_account!.unlock_funds!(order.locked)
        order.record_cancel_operations!

        order.update!(state: ::Order::CANCEL)
      end
    end

    def trigger_bulk_cancel_third_party(engine_driver, filters = {})
      AMQP::Queue.publish(engine_driver,
                          data: filters,
                          type: THIRD_PARTY_ORDER_ACTION_TYPE['cancel_bulk'])
    end

    def to_csv
      attributes = %w[id market_id market_type ord_type side price volume origin_volume avg_price trades_count state created_at updated_at]

      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |order|
          data = attributes[0...-2].map { |attr| order.send(attr) }
          data += attributes[-2..-1].map { |attr| order.send(attr).iso8601 }
          csv << data
        end
      end
    end
  end

  def submit_order
    return unless new_record?

    self.locked = self.origin_locked = if ord_type == 'market' && side == 'buy'
                                         [compute_locked * OrderBid::LOCKING_BUFFER_FACTOR, member_balance].min
                                       else
                                         compute_locked
                                       end

    raise ::Account::AccountError unless member_balance >= locked

    return trigger_third_party_creation unless market.engine.peatio_engine?

    save!
    AMQP::Queue.enqueue(:order_processor,
                        { action: 'submit', order: attributes },
                        { persistent: false })
  end

  def trigger_third_party_creation
    return unless new_record?

    self.uuid ||= UUID.generate
    self.created_at ||= Time.now

    AMQP::Queue.publish(market.engine.driver, data: as_json_for_third_party, type: THIRD_PARTY_ORDER_ACTION_TYPE['submit_single'])
  end

  def trigger_cancellation
    market.engine.peatio_engine? ? trigger_internal_cancellation : trigger_third_party_cancellation
  end

  def trigger_internal_cancellation
    AMQP::Queue.enqueue(:matching, action: 'cancel', order: to_matching_attributes)
  end

  def trigger_third_party_cancellation
    AMQP::Queue.publish(market.engine.driver,
                        data: as_json_for_third_party,
                        type: THIRD_PARTY_ORDER_ACTION_TYPE['cancel_single'])
  end

  def trades
    Trade.where('market_type = ? AND (maker_order_id = ? OR taker_order_id = ?)', market_type, id, id)
  end

  def funds_used
    origin_locked - locked
  end

  def trigger_event
    # skip market type orders, they should not appear on trading-ui
    return unless ord_type == 'limit' || state == 'done'

    ::AMQP::Queue.enqueue_event('private', member&.uid, 'order', for_notify)
  end

  def side
    self.class.name.underscore[-3, 3] == 'ask' ? 'sell' : 'buy'
  end

  # @deprecated Please use {#side} instead
  def kind
    self.class.name.underscore[-3, 3]
  end

  # @deprecated Please use {#created_at} instead
  def at
    created_at.to_i
  end

  def for_notify
    {
      id:               id,
      market:           market_id,
      kind:             kind,
      side:             side,
      ord_type:         ord_type,
      price:            price&.to_s('F'),
      avg_price:        avg_price&.to_s('F'),
      state:            state,
      origin_volume:    origin_volume.to_s('F'),
      remaining_volume: volume.to_s('F'),
      executed_volume:  (origin_volume - volume).to_s('F'),
      at:               at,
      created_at:       created_at.to_i,
      updated_at:       updated_at.to_i,
      trades_count:     trades_count
    }
  end

  def to_matching_attributes
    { id:        id,
      market:    market_id,
      type:      type[-3, 3].downcase.to_sym,
      ord_type:  ord_type,
      volume:    volume,
      price:     price,
      locked:    locked,
      timestamp: created_at.to_i }
  end

  def as_json_for_events_processor
    { id:            id,
      member_id:     member_id,
      member_uid:    member.uid,
      ask:           ask,
      bid:           bid,
      type:          type,
      ord_type:      ord_type,
      price:         price,
      volume:        volume,
      origin_volume: origin_volume,
      market_id:     market_id,
      maker_fee:     maker_fee,
      taker_fee:     taker_fee,
      locked:        locked,
      state:         read_attribute_before_type_cast(:state) }
  end

  def as_json_for_third_party
    {
        uuid:           uuid,
        market_id:      market_id,
        member_uid:     member.uid,
        origin_volume:  origin_volume,
        volume:         volume,
        price:          price,
        side:           type,
        type:           ord_type,
        created_at:     created_at.to_i
    }
  end

  # @deprecated
  def round_amount_and_price
    self.price = market.round_price(price.to_d) if price

    if volume
      self.volume = market.round_amount(volume.to_d)
      self.origin_volume = origin_volume.present? ? market.round_amount(origin_volume.to_d) : volume
    end
  end

  def record_submit_operations!
    transaction do
      # Debit main fiat/crypto Liability account.
      # Credit locked fiat/crypto Liability account.
      Operations::Liability.transfer!(
        amount:     locked,
        currency:   currency,
        reference:  self,
        from_kind:  :main,
        to_kind:    :locked,
        member_id:  member_id
      )
    end
  end

  def record_cancel_operations!
    transaction do
      # Debit locked fiat/crypto Liability account.
      # Credit main fiat/crypto Liability account.
      Operations::Liability.transfer!(
        amount:     locked,
        currency:   currency,
        reference:  self,
        from_kind:  :locked,
        to_kind:    :main,
        member_id:  member_id
      )
    end
  end

  def is_limit_order?
    ord_type == 'limit'
  end

  def member_balance
    member.get_account(currency).balance
  end

  private

  def market_order_validations
    errors.add(:price, 'must not be present') if price.present?
  end

  FUSE = '0.9'.to_d
  def estimate_required_funds(price_levels)
    required_funds = Account::ZERO
    expected_volume = volume

    until expected_volume.zero? || price_levels.empty?
      level_price, level_volume = price_levels.shift

      v = [expected_volume, level_volume].min
      required_funds += yield level_price, v
      expected_volume -= v
    end

    raise InsufficientMarketLiquidity if expected_volume.nonzero?

    required_funds
  end
end

# == Schema Information
# Schema version: 20210805134633
#
# Table name: orders
#
#  id             :bigint           not null, primary key
#  uuid           :binary(16)       not null
#  remote_id      :string(255)
#  bid            :string(10)       not null
#  ask            :string(10)       not null
#  market_id      :string(20)       not null
#  market_type    :string(255)      default("spot"), not null
#  trigger_price  :decimal(32, 16)
#  triggered_at   :datetime
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)  not null
#  origin_volume  :decimal(32, 16)  not null
#  maker_fee      :decimal(17, 16)  default(0.0), not null
#  taker_fee      :decimal(17, 16)  default(0.0), not null
#  state          :integer          not null
#  type           :string(8)        not null
#  member_id      :bigint           not null
#  ord_type       :string(30)       not null
#  locked         :decimal(32, 16)  default(0.0), not null
#  origin_locked  :decimal(32, 16)  default(0.0), not null
#  funds_received :decimal(32, 16)  default(0.0)
#  trades_count   :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_orders_on_member_id                                     (member_id)
#  index_orders_on_state                                         (state)
#  index_orders_on_type_and_market_id_and_market_type            (type,market_id,market_type)
#  index_orders_on_type_and_member_id                            (type,member_id)
#  index_orders_on_type_and_state_and_market_id_and_market_type  (type,state,market_id,market_type)
#  index_orders_on_type_and_state_and_member_id                  (type,state,member_id)
#  index_orders_on_updated_at                                    (updated_at)
#  index_orders_on_uuid                                          (uuid) UNIQUE
#
