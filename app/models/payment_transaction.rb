class PaymentTransaction < ActiveRecord::Base
  include AASM
  include AASM::Locking
  extend ActiveHash::Associations::ActiveRecordExtensions

  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true
  enumerize :aasm_state, in: [:unconfirm, :confirming, :confirmed], scope: true

  validates_uniqueness_of :txid
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
    end
  end

  def min_confirm?
    deposit.min_confirm?(confirmations)
  end

  def max_confirm?
    deposit.max_confirm?(confirmations)
  end

  def refresh_confirmations
    raw = CoinRPC[deposit.currency].gettransaction(txid)
    self.confirmations = raw[:confirmations]
    save!
  end

  def deposit_submit
    self.deposit = create_deposit \
      txid: txid,
      amount: amount,
      member: member,
      account: account,
      currency: currency
    self.deposit.submit!
  end

  def deposit_accept
    if deposit.may_accept?
      deposit.accept! 
    end
  end
end
