class Deposit < ActiveRecord::Base
  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  attr_accessor :save_fund_source

  STATE = [:submitting, :cancelled, :submitted, :rejected, :accepted, :checked, :warning]

  alias_attribute :sn, :id

  delegate :key_text, to: :channel, prefix: true
  delegate :full_name, to: :member

  belongs_to :member
  belongs_to :account

  after_create :create_fund_source, if: :save_fund_source?

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

  def save_fund_source?
    [true, 'true', '1', 1].include? @save_fund_source
  end

  def create_fund_source
    FundSource.find_or_create_by \
      member: member,
      currency: currency_value,
      channel_id: channel.id,
      uid: fund_uid,
      extra: fund_extra
  end
end
