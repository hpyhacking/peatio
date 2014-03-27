class Deposit < ActiveRecord::Base
  include AASM
  include AASM::Locking
  extend ActiveHash::Associations::ActiveRecordExtensions

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  belongs_to :member
  belongs_to :account
  belongs_to :channel, class_name: 'DepositChannel'

  validates_presence_of \
    :channel, :amount, :account, \
    :member, :currency, :aasm_state, :txid
  validates_uniqueness_of :txid

  attr_accessor :sn

  aasm :whiny_transitions => false do
    state :submitting, initial: true, before_enter: :compute_fee
    state :submitted
    state :rejected
    state :accepted
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
      after :do
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

  def compute_fee
    channel_amount, channel_fee = self.channel.compute_fee(self)
    self.amount = channel_amount
    self.fee = channel_fee
  end
end
