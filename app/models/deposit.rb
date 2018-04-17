class Deposit < ActiveRecord::Base
  STATES = %i[submitted canceled rejected accepted].freeze

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible
  include TIDIdentifiable

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  delegate :coin?, :fiat?, to: :currency

  belongs_to :member, required: true

  validates :amount, :fee, :tid, :aasm_state, :type, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  validates :fee, numericality: { greater_than_or_equal_to: 0.0 }
  validates :completed_at, presence: { if: :completed? }

  scope :recent, -> { order(id: :desc) }

  after_create :sync_create
  after_update :sync_update
  after_destroy :sync_destroy

  before_validation { self.completed_at ||= Time.current if completed? }

  aasm whiny_transitions: false do
    state :submitted, initial: true, before_enter: :set_fee
    state :canceled
    state :rejected
    state :accepted
    event(:cancel) { transitions from: :submitted, to: :canceled }
    event(:reject) { transitions from: :submitted, to: :rejected }
    event :accept do
      transitions from: :submitted, to: :accepted
      after { account.lock!.plus_funds(amount, reason: Account::DEPOSIT, ref: self) }
    end
  end

  def account
    member&.ac(currency)
  end

  def sn
    member&.sn
  end

  def sn=(sn)
    self.member = Member.find_by_sn(sn)
  end

private

  def completed?
    !submitted?
  end

  def set_fee
    amount, fee = calc_fee
    self.amount = amount
    self.fee = fee
  end

  def calc_fee
    [amount, 0]
  end

  def sync_update
    Pusher["private-#{member.sn}"].trigger_async('deposits', type: 'update', id: id, attributes: as_json.merge(currency: currency.code))
  end

  def sync_create
    Pusher["private-#{member.sn}"].trigger_async('deposits', type: 'create', attributes: as_json.merge(currency: currency.code))
  end

  def sync_destroy
    Pusher["private-#{member.sn}"].trigger_async('deposits', type: 'destroy', id: id)
  end
end

# == Schema Information
# Schema version: 20180409115902
#
# Table name: deposits
#
#  id            :integer          not null, primary key
#  member_id     :integer          not null
#  currency_id   :integer          not null
#  amount        :decimal(32, 16)  not null
#  fee           :decimal(32, 16)  not null
#  address       :string(64)
#  txid          :string(128)
#  txout         :integer
#  aasm_state    :string           not null
#  confirmations :integer          default(0), not null
#  type          :string(30)       not null
#  tid           :string(64)       not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  completed_at  :datetime
#
# Indexes
#
#  index_deposits_on_currency_id                     (currency_id)
#  index_deposits_on_currency_id_and_txid_and_txout  (currency_id,txid,txout) UNIQUE
#  index_deposits_on_type                            (type)
#
