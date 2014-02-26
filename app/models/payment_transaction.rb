class PaymentTransaction < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true
  enumerize :state, in: {:unconfirm => 100, :warning => 101, :confirming => 150, :confirmed => 200}, scope: true
  
  validates_uniqueness_of :txid
  belongs_to :payment_address, foreign_key: 'address', primary_key: 'address'

  def config
    @config ||= DepositChannel.find_by_currency(self.currency)
    raise "known deposits config for #{self.account.currency}" unless @config
    @config
  end

  def check(raw)
    unless self.payment_address
      self.state = :warning
      self.save
      return false
    end

    if self.account.currency != self.currency
      self.state = :warning
      self.save
      return false
    end

    return false unless self.state.unconfirm? ## lock double check
    return false if raw[:confirmations] < config[:confirm]
    return true
  end

  def deposit!(raw)
    deposit = Deposit.create! \
      :state => :done,
      :address => self.payment_address.address,
      :address_type => config[:id],
      :currency => config[:currency],
      :address_label => "daemon",
      :account_id => self.account.id,
      :member_id => self.account.member.id,
      :amount => self.amount,
      :tx_id => self.txid,
      :done_at => DateTime.now

    detail = {
      :payment_id => self.txid, 
      :payment_address => self.payment_address.address,
      :tmp => "#{account.currency}.#{Account::DEPOSIT}"
    }

    account.plus_funds self.amount, reason: Account::DEPOSIT, ref: deposit
  end

  def confirm!(raw)
    if raw[:confirmations] >= config[:confirm_max]
      self.state = :confirmed
    else
      self.state = :confirming
    end

    self.confirmations = raw[:confirmations]
    self.save!
  end

  def account
    self.payment_address.account
  end

  def self.deposit(txid)
  end
end
