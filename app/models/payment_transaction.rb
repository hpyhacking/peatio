class PaymentTransaction < ActiveRecord::Base
  include AASM
  include AASM::Locking
  extend ActiveHash::Associations::ActiveRecordExtensions

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  validates_uniqueness_of :txid
  belongs_to :channel, class_name: 'DepositChannel'
  belongs_to :deposit, foreign_key: 'txid', primary_key: 'txid'
  belongs_to :payment_address, foreign_key: 'address', primary_key: 'address'
  has_one :account, through: :payment_address
  has_one :member, through: :account

  after_create :deposit_submit

  aasm do
    state :unconfirm, initial: true
    state :confirming, after_commit: :deposit_accept
    state :confirmed, after_commit: :deposit_accept
    state :warning

    event :check do |e|
      before :refresh_confirmations

      transitions :from => :unconfirm, :to => :unconfirm, :guard => :zero_confirm?
      transitions :from => [:unconfirm, :confirming], :to => :confirming, :guard => :min_confirm?
      transitions :from => [:unconfirm, :confirming, :confirmed], :to => :confirmed, :guard => :max_confirm?

      after :update_deposit
    end
  end

  def zero_confirm?
    self.confirmations < channel.min_confirm
  end

  def min_confirm?
    self.confirmations >= channel.min_confirm && self.confirmations < channel.max_confirm
  end

  def max_confirm?
    self.confirmations >= channel.max_confirm
  end

  def refresh_confirmations
    raw = CoinRPC[channel.currency].gettransaction(self.txid)
    self.confirmations = raw[:confirmations]
    self.save
  end

  def deposit_submit
    self.deposit = self.create_deposit \
      txid: self.txid,
      amount: self.amount,
      member: self.member,
      account: self.account,
      channel: self.channel,
      currency: self.currency
    self.deposit.submit!
  end

  def deposit_accept
    self.deposit.accept! if self.deposit.submitted?
  end

  def update_deposit
    self.deposit.update_memo(self.confirmations)
  end
end
