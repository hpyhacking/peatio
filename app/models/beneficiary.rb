# encoding: UTF-8
# frozen_string_literal: true

class Beneficiary < ApplicationRecord

  # == Constants ============================================================

  extend Enumerize

  include AASM
  include AASM::Locking

  STATES_MAPPING = { pending: 0, active: 1, archived: 2 }.freeze

  STATES = %i[pending active archived].freeze
  STATES_AVAILABLE_FOR_MEMBER = %i[pending active]

  PIN_LENGTH  = 6
  PIN_RANGE   = 10**5..10**Beneficiary::PIN_LENGTH

  # == Attributes ===========================================================

  attr_readonly :pin

  # == Extensions ===========================================================

  enumerize :state, in: STATES_MAPPING, scope: true

  aasm column: :state, enum: :states_mapping, whiny_transitions: false do
    state :pending, initial: true
    state :active
    state :archived

    event :activate do
      transitions from: :pending, to: :active, guard: :valid_pin?
    end

    event :archive do
      transitions from: %i[pending active], to: :archived
    end
  end

  acts_as_eventable prefix: 'beneficiary', on: %i[create update]

  # == Relationships ========================================================

  belongs_to :currency, required: true
  belongs_to :member, required: true

  # == Validations ==========================================================

  validates :pin, presence: true, numericality: { only_integer: true }

  validates :data, presence: true

  # Validates that data contains address field which is required for coin.
  validate if: ->(b) { b.currency.present? && b.currency.coin? } do
    errors.add(:data, 'address can\'t be blank') if data.blank? || data['address'].blank?
  end

  # Validates that data contains full_name field which is required for fiat.
  validate if: ->(b) { b.currency.present? && b.currency.fiat? } do
    errors.add(:data, 'full_name can\'t be blank') if data.blank? || data['full_name'].blank?
  end

  # == Scopes ===============================================================

  scope :available_to_member, -> { with_state(:pending, :active) }

  # == Callbacks ============================================================

  before_validation(on: :create) do
    self.pin ||= self.class.generate_pin
  end

  # == Class Methods ========================================================

  class << self
    def generate_pin
      SecureRandom.rand(Beneficiary::PIN_RANGE)
    end

    # Method used for passing states mapping to AASM.
    def states_mapping
      STATES_MAPPING
    end
  end

  # == Instance Methods =====================================================

  def as_json_for_event_api
    { user:        { uid: member.uid, email: member.email },
      currency:    currency_id,
      name:        name,
      description: description,
      data:        data,
      pin:         pin,
      state:       state,
      created_at:  created_at.iso8601,
      updated_at:  updated_at.iso8601 }
  end

  def valid_pin?(user_pin)
    case user_pin
    when Integer
      return pin == user_pin
    when String
      return pin == user_pin.to_i
    else
      return false
    end
  end

  def rid
    currency.coin? ? coin_rid : fiat_rid
  end

  private

  def coin_rid
    return unless currency.coin?
    data['address']
  end

  def fiat_rid
    return unless currency.fiat?
    "%s-%s-%08d" % [data['full_name'].downcase.split.join('-'), currency_id.downcase, id]
  end
end

# == Schema Information
# Schema version: 20190829152927
#
# Table name: beneficiaries
#
#  id          :bigint           not null, primary key
#  member_id   :bigint           not null
#  currency_id :string(10)       not null
#  name        :string(64)       not null
#  description :string(255)      default("")
#  data        :json
#  pin         :integer          unsigned, not null
#  state       :integer          default("pending"), unsigned, not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_beneficiaries_on_currency_id  (currency_id)
#  index_beneficiaries_on_member_id    (member_id)
#
