class Deposit < ActiveRecord::Base
  STATES = [:submitting, :cancelled, :submitted, :rejected, :accepted, :checked, :warning]

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  alias_attribute :sn, :id

  delegate :id, to: :channel, prefix: true
  delegate :coin?, :fiat?, to: :currency_obj

  belongs_to :member
  belongs_to :account

  validates_presence_of \
    :amount, :account, \
    :member, :currency
  validates_numericality_of :amount, greater_than: 0

  scope :recent, -> { order('id DESC')}

  after_update :sync_update
  after_create :sync_create
  after_destroy :sync_destroy

  aasm :whiny_transitions => false do
    state :submitting, initial: true, before_enter: :set_fee
    state :cancelled
    state :submitted
    state :rejected
    state :accepted
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

    event :accept, after_commit: %i[ do send_mail ] do
      transitions from: :submitted, to: :accepted
    end

    event :check do
      transitions from: :accepted, to: :checked
    end

    event :warn do
      transitions from: :accepted, to: :warning
    end
  end

  def txid_desc
    txid
  end

  class << self
    def channel
      DepositChannel.find_by_key(name.demodulize.underscore)
    end

    def resource_name
      name.demodulize.underscore.pluralize
    end

    def params_name
      name.underscore.gsub('/', '_')
    end

    def new_path
      "new_#{params_name}_path"
    end
  end

  def channel
    self.class.channel
  end

  def update_confirmations(data)
    update_column(:confirmations, data)
  end

  def txid_text
    txid && txid.truncate(40)
  end

  private
  def do
    account.lock!.plus_funds amount, reason: Account::DEPOSIT, ref: self
  end

  def send_mail
    DepositMailer.accepted(self.id).deliver if self.accepted?
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
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end

  def sync_create
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'create', attributes: self.as_json })
  end

  def sync_destroy
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'destroy', id: self.id })
  end
end

# == Schema Information
# Schema version: 20180215144645
#
# Table name: deposits
#
#  id                     :integer          not null, primary key
#  account_id             :integer
#  member_id              :integer
#  currency               :integer
#  amount                 :decimal(32, 16)
#  fee                    :decimal(32, 16)
#  fund_uid               :string(255)
#  fund_extra             :string(255)
#  txid                   :string(255)
#  state                  :integer
#  aasm_state             :string
#  created_at             :datetime
#  updated_at             :datetime
#  done_at                :datetime
#  confirmations          :string(255)
#  type                   :string(255)
#  payment_transaction_id :integer
#  txout                  :integer
#
# Indexes
#
#  index_deposits_on_txid_and_txout  (txid,txout)
#
