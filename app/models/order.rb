# encoding: UTF-8
# frozen_string_literal: true

class Order < ApplicationRecord
  include BelongsToMarket
  include BelongsToMember

  # Error is raised in case market doesn't have enough volume to fulfill the Order.
  InsufficientMarketLiquidity = Class.new(StandardError)

  extend Enumerize
  STATES = { pending: 0, wait: 100, done: 200, cancel: -100, reject: -200 }.freeze
  enumerize :state, in: STATES, scope: true

  TYPES = %w[ market limit ]
  enumerize :ord_type, in: TYPES, scope: true

  after_commit :trigger_pusher_event

  validates :ord_type, :volume, :origin_volume, :locked, :origin_locked, presence: true
  validates :price, numericality: { greater_than: 0 }, if: ->(order) { order.ord_type == 'limit' }

  validates :origin_volume,
            presence: true,
            numericality: { greater_than: 0, greater_than_or_equal_to: ->(order){ order.market.min_amount } }
  validate do
    if origin_volume.present? && !market.valid_precision?(origin_volume, market.amount_precision)
      errors.add(:origin_volume, 'is too precise')
    end
  end

  validate  :market_order_validations, if: ->(order) { order.ord_type == 'market' }

  validates :price, presence: true, if: :is_limit_order?
  validate do
    if price.present? && !market.valid_precision?(price, market.price_precision)
      errors.add(:price, 'is too precise')
    end
  end

  validates :price,
            numericality: { less_than_or_equal_to: ->(order){ order.market.max_price }},
            if: ->(order) { order.is_limit_order? && order.market.max_price.nonzero? }

  validates :price,
            numericality: { greater_than_or_equal_to: ->(order){ order.market.min_price }},
            if: :is_limit_order?

  PENDING = 'pending'
  WAIT    = 'wait'
  DONE    = 'done'
  CANCEL  = 'cancel'
  REJECT  = 'reject'

  scope :done, -> { with_state(:done) }
  scope :active, -> { with_state(:wait) }

  before_validation(on: :create) { self.fee = market.public_send("#{kind}_fee") }

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

        AMQPQueue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
      end
    rescue => e
      order = find_by_id!(id)
      order.update!(state: ::Order::REJECT) if order
      report_exception_to_screen(e)
    end

    def cancel(id)
      ActiveRecord::Base.transaction do
        order = lock.find_by_id!(id)
        return unless order.state == ::Order::WAIT

        order.hold_account!.unlock_funds!(order.locked)
        order.record_cancel_operations!

        order.update!(state: ::Order::CANCEL)
      end
    rescue => e
      report_exception_to_screen(e)
    end
  end

  def funds_used
    origin_locked - locked
  end

  def trigger_pusher_event
    # skip market type orders, they should not appear on trading-ui
    return unless ord_type == 'limit' || state == 'done'

    Member.trigger_pusher_event member_id, :order, \
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
      fee:           fee,
      locked:        locked,
      state:         read_attribute_before_type_cast(:state) }
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
# Schema version: 20190213104708
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  bid            :string(10)       not null
#  ask            :string(10)       not null
#  market_id      :string(20)       not null
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)  not null
#  origin_volume  :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  default(0.0), not null
#  state          :integer          not null
#  type           :string(8)        not null
#  member_id      :integer          not null
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
#  index_orders_on_member_id                     (member_id)
#  index_orders_on_state                         (state)
#  index_orders_on_type_and_market_id            (type,market_id)
#  index_orders_on_type_and_member_id            (type,member_id)
#  index_orders_on_type_and_state_and_market_id  (type,state,market_id)
#  index_orders_on_type_and_state_and_member_id  (type,state,member_id)
#  index_orders_on_updated_at                    (updated_at)
#
