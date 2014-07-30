# == Schema Information
#
# Table name: deposits
#
#  id         :integer          not null, primary key
#  account_id :integer
#  member_id  :integer
#  currency   :integer
#  amount     :decimal(32, 16)
#  fee        :decimal(32, 16)
#  fund_uid   :string(255)
#  fund_extra :string(255)
#  txid       :string(255)
#  state      :integer
#  aasm_state :string(255)
#  created_at :datetime
#  updated_at :datetime
#  done_at    :datetime
#  memo       :string(255)
#  type       :string(255)
#

class Deposit < ActiveRecord::Base
  STATES = [:submitting, :cancelled, :submitted, :rejected, :accepted, :checked, :warning]

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  alias_attribute :sn, :id

  delegate :name, to: :member, prefix: true
  delegate :id, to: :channel, prefix: true

  belongs_to :member
  belongs_to :account

  validates_presence_of \
    :amount, :account, \
    :member, :currency
  validates_numericality_of :amount, greater_than: 0

  aasm :whiny_transitions => false do
    state :submitting, initial: true, before_enter: :set_fee
    state :cancelled
    state :submitted
    state :rejected
    state :accepted, after_commit: :do
    state :checked
    state :warning

    event :submit do
      transitions from: :submitting, to: :submitted
    end

    event :cancel do
      transitions from: :submitting, to: :cancelled
    end

    event :reject do
      transitions from: :submitted, to: :rejected
    end

    event :accept do
      transitions from: :submitted, to: :accepted
    end

    event :check do
      transitions from: :accepted, to: :checked
    end

    event :warn do
      transitions from: :accepted, to: :warning
    end
  end

  def update_memo(data)
    self.update_column(:memo, data)
  end

  def self.channel
    DepositChannel.find_by_key(name.demodulize.underscore)
  end

  def channel
    self.class.channel
  end

  def self.resource_name
    name.demodulize.underscore.pluralize
  end

  def self.params_name
    name.underscore.gsub('/', '_')
  end

  def self.new_path
    "new_#{params_name}_path"
  end

  def txid_text
    txid && txid.truncate(40)
  end

  private
  def do
    account.lock!.plus_funds amount, reason: Account::DEPOSIT, ref: self
  end

  def set_fee
    amount, fee = calc_fee
    self.amount = amount
    self.fee = fee
  end

  def calc_fee
    [amount, 0]
  end
end
