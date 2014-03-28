class PaymentTransaction < ActiveRecord::Base
  include AASM
  include AASM::Locking
  extend ActiveHash::Associations::ActiveRecordExtensions

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true
  enumerize :aasm_state, in: [:unconfirm, :confirming, :confirmed], scope: true

  validates_uniqueness_of :txid
  belongs_to :channel, class_name: 'DepositChannel'
  belongs_to :deposit, foreign_key: 'txid', primary_key: 'txid'
  belongs_to :payment_address, foreign_key: 'address', primary_key: 'address'
  has_one :account, through: :payment_address
  has_one :member, through: :account

  after_create :deposit_submit

  aasm :whiny_transitions => false do
    state :unconfirm, initial: true
    state :confirming, after_commit: :deposit_accept
    state :confirmed, after_commit: :deposit_accept

    event :check do |e|
      before :refresh_confirmations

      transitions :from => [:unconfirm, :confirming], :to => :confirming, :guard => :min_confirm?
      transitions :from => [:unconfirm, :confirming, :confirmed], :to => :confirmed, :guard => :max_confirm?

      after :update_deposit
    end
  end

  def min_confirm?
    confirmations >= channel.min_confirm && confirmations < channel.max_confirm
  end

  def max_confirm?
    confirmations >= channel.max_confirm
  end

  def refresh_confirmations
    raw = CoinRPC[channel.currency].gettransaction(txid)
    self.confirmations = raw[:confirmations]
    save!
  end

  def deposit_submit
    deposit = create_deposit \
      txid: txid,
      amount: amount,
      member: member,
      account: account,
      channel: channel,
      currency: currency
    deposit.submit!
  end

  def deposit_accept
    if deposit.may_accept?
      deposit.accept! 
    end
  end

  def update_deposit
    if deposit.memo != confirmations.to_s
      deposit.update_memo(confirmations)
    end
  end
end
