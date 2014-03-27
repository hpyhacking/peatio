class Deposit < ActiveRecord::Base
  include AASM
  include AASM::Locking

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  belongs_to :member
  belongs_to :account

  validates_presence_of \
    :channel_id, :fund_source_uid, :fund_source_extra,
    :amount, :fee, :account, :member, :currency, :aasm_state, :txid
  validates_uniqueness_of :txid

  def channel
    DepositChannel.find(channel_id)
  end

  attr_accessor :sn

  aasm do
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
