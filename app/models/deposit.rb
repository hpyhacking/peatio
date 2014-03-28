class Deposit < ActiveRecord::Base
  include AASM
  include AASM::Locking
  extend ActiveHash::Associations::ActiveRecordExtensions

  STATE = [:submitting, :submitted, :rejected, :accepted, :checked, :warning]

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true
  enumerize :aasm_state, in: STATE, scope: true

  belongs_to :member
  belongs_to :account

  validates_presence_of \
    :amount, :account, \
    :member, :currency, :aasm_state, :txid
  validates_uniqueness_of :txid

  attr_accessor :sn

  aasm :whiny_transitions => false do
    state :submitting, initial: true, before_enter: :set_fee
    state :submitted
    state :rejected
    state :accepted, after_commit: :do
    state :checked
    state :warning

    event :submit do
      transitions from: :submitting, to: :submitted
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
