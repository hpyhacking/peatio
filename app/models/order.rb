class Order < ActiveRecord::Base
  extend Enumerize

  belongs_to :market
  enumerize :state, in: {:wait => 100, :done => 200, :cancel => 0}, scope: true

  ORD_TYPES = %w(market limit)
  enumerize :ord_type, in: ORD_TYPES, scope: true

  SOURCES = %w(Web APIv2 debug)
  enumerize :source, in: SOURCES, scope: true

  after_commit :trigger
  before_validation :fix_number_precision, on: :create

  validates_presence_of :ord_type, :volume, :origin_volume, :locked, :origin_locked
  validates_numericality_of :origin_volume, :greater_than => 0

  validates_numericality_of :price, greater_than: 0, allow_nil: false,
    if: "ord_type == 'limit'"
  validate :market_order_validations, if: "ord_type == 'market'"

  WAIT = 'wait'
  DONE = 'done'
  CANCEL = 'cancel'

  ATTRIBUTES = %w(id at market kind price state state_text volume origin_volume)

  belongs_to :member
  attr_accessor :total

  scope :done, -> { with_state(:done) }
  scope :active, -> { with_state(:wait) }
  scope :position, -> { group("price").pluck(:price, 'sum(volume)') }
  scope :best_price, ->(currency) { where(ord_type: 'limit').active.with_market(currency).matching_rule.position }
  scope :with_market, -> (market) { where(market: Market === market ? market : Market.find(market)) }

  before_validation(on: :create) { self.fee = config.public_send("#{kind}_fee") }

  def funds_used
    origin_locked - locked
  end

  def config
    @config ||= Market.find(market_id)
  end

  def trigger
    return unless member

    json = Jbuilder.encode do |json|
      json.(self, *ATTRIBUTES)
    end
    member.trigger('order', json)
  end

  def strike(trade)
    raise "Cannot strike on canceled or done order. id: #{id}, state: #{state}" unless state == Order::WAIT

    real_sub, add = get_account_changes trade
    real_fee      = add * fee
    real_add      = add - real_fee

    hold_account.unlock_and_sub_funds \
      real_sub, locked: real_sub,
      reason: Account::STRIKE_SUB, ref: trade

    expect_account.plus_funds \
      real_add, fee: real_fee,
      reason: Account::STRIKE_ADD, ref: trade

    self.volume         -= trade.volume
    self.locked         -= real_sub
    self.funds_received += add
    self.trades_count   += 1

    if volume.zero?
      self.state = Order::DONE

      # unlock not used funds
      hold_account.unlock_funds locked,
        reason: Account::ORDER_FULFILLED, ref: trade unless locked.zero?
    elsif ord_type == 'market' && locked.zero?
      # partially filled market order has run out its locked fund
      self.state = Order::CANCEL
    end

    self.save!
  end

  def kind
    self.class.name.underscore[-3, 3]
  end

  def self.head(currency)
    active.with_market(currency).matching_rule.first
  end

  def at
    created_at.to_i
  end

  def to_matching_attributes
    { id: id,
      market: market.id,
      type: type[-3, 3].downcase.to_sym,
      ord_type: ord_type,
      volume: volume,
      price: price,
      locked: locked,
      timestamp: created_at.to_i }
  end

  def fix_number_precision
    self.price = config.fix_number_precision(:bid, price.to_d) if price

    if volume
      self.volume = config.fix_number_precision(:ask, volume.to_d)
      self.origin_volume = origin_volume.present? ? config.fix_number_precision(:ask, origin_volume.to_d) : volume
    end
  end

  private

  def market_order_validations
    errors.add(:price, 'must not be present') if price.present?
  end

  FUSE = '0.9'.to_d
  def estimate_required_funds(price_levels)
    required_funds = Account::ZERO
    expected_volume = volume

    start_from, _ = price_levels.first
    filled_at     = start_from

    until expected_volume.zero? || price_levels.empty?
      level_price, level_volume = price_levels.shift
      filled_at = level_price

      v = [expected_volume, level_volume].min
      required_funds += yield level_price, v
      expected_volume -= v
    end

    raise "Market is not deep enough" unless expected_volume.zero?
    raise "Volume too large" if (filled_at-start_from).abs/start_from > FUSE

    required_funds
  end

end

# == Schema Information
# Schema version: 20180417175453
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  bid            :integer
#  ask            :integer
#  market_id      :string(10)
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)
#  origin_volume  :decimal(32, 16)
#  fee            :decimal(32, 16)  default(0.0), not null
#  state          :integer
#  done_at        :datetime
#  type           :string(8)
#  member_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  sn             :string(255)
#  source         :string           not null
#  ord_type       :string
#  locked         :decimal(32, 16)
#  origin_locked  :decimal(32, 16)
#  funds_received :decimal(32, 16)  default(0.0)
#  trades_count   :integer          default(0)
#
# Indexes
#
#  index_orders_on_market_id_and_state  (market_id,state)
#  index_orders_on_member_id            (member_id)
#  index_orders_on_member_id_and_state  (member_id,state)
#  index_orders_on_state                (state)
#
