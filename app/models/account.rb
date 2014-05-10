class Account < ActiveRecord::Base
  include Currencible

  validates :member_id, uniqueness: { scope: :currency }

  after_commit :trigger

  FIX = :fix
  UNKNOWN = :unknown
  STRIKE_ADD = :strike_add
  STRIKE_SUB = :strike_sub
  STRIKE_FEE = :strike_fee
  STRIKE_UNLOCK = :strike_unlock
  ORDER_CANCEL = :order_cancel
  ORDER_SUBMIT = :order_submit
  WITHDRAW_LOCK = :withdraw_lock
  WITHDRAW_UNLOCK = :withdraw_unlock
  DEPOSIT = :deposit
  WITHDRAW = :withdraw
  ZERO = 0.to_d

  FUNS = {:unlock_funds => 1, :lock_funds => 2, :plus_funds => 3, :sub_funds => 4, :unlock_and_sub_funds => 5}

  belongs_to :member
  has_many :fund_sources
  has_many :payment_addresses
  has_many :versions, class_name: "::AccountVersion"
  has_many :partial_trees

  def payment_address
    if self.payment_addresses.empty?
      self.gen_payment_address 
    end
    self.payment_addresses.using
  end

  def gen_payment_address
    address = CoinRPC[self.currency].getnewaddress("payment")
    self.payment_addresses.create(address: address, currency: self.currency)
  end

  def self.after(*names)
    names.each do |name|
      m = instance_method(name.to_s)
      define_method(name.to_s) do |*args, &block|  
        m.bind(self).(*args, &block)
        yield(self, name.to_sym, *args)
        self
      end
    end
  end

  def plus_funds(amount, fee: ZERO, reason: nil, ref: nil)
    (amount <= ZERO or fee > amount) and raise AccountError, "cannot add funds (amount: #{amount})"
    self.balance += amount
    self.save
    self
  end

  def sub_funds(amount, fee: ZERO, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.balance) and raise AccountError, "cannot subtract funds (amount: #{amount})"
    self.balance -= amount
    self.save
    self
  end

  def lock_funds(amount, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.balance) and raise AccountError, "cannot lock funds (amount: #{amount})"
    self.balance -= amount
    self.locked += amount
    self.save
    self
  end

  def unlock_funds(amount, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.locked) and raise AccountError, "cannot unlock funds (amount: #{amount})"
    self.balance += amount
    self.locked -= (amount)
    self.save
    self
  end

  def unlock_and_sub_funds(amount, locked: ZERO, fee: ZERO, reason: nil, ref: nil)
    raise AccountError, "cannot unlock and subtract funds (amount: #{amount})" if ((amount <= 0) or (amount > locked))
    raise LockedError, "invalid lock amount" unless locked
    raise LockedError, "invalid lock amount" if ((locked <= 0) or (locked > self.locked))
    self.balance += (locked - amount)
    self.locked -= (locked)
    self.save
    self
  end

  after(*FUNS.keys) do |account, fun, changed, opts|
    opts ||= {}
    fee = opts[:fee] || ZERO
    reason = opts[:reason] || Account::UNKNOWN

    attributes = {
      fun: fun, fee: fee, reason: reason, amount: account.amount,
      currency: account.currency, member_id: account.member_id }

    if opts[:ref] and opts[:ref].respond_to?(:id)
      ref_klass = opts[:ref].class
      attributes.merge! \
        modifiable_id: opts[:ref].id,
        modifiable_type: ref_klass.respond_to?(:base_class) ? ref_klass.base_class.name : ref_klass.name
    end

    locked, balance = compute_locked_and_balance(fun, changed, opts)
    attributes.merge! locked: locked, balance: balance

    account.versions.create(attributes)
  end

  def self.compute_locked_and_balance(fun, amount, opts)
    raise AccountError, "invalid account operation" unless FUNS.keys.include?(fun)

    case fun
    when :sub_funds then [ZERO, ZERO - amount]
    when :plus_funds then [ZERO, amount]
    when :lock_funds then [amount, ZERO - amount]
    when :unlock_funds then [ZERO - amount, amount]
    when :unlock_and_sub_funds
      locked = ZERO - opts[:locked]
      balance = opts[:locked] - amount
      [locked, balance]
    else raise AccountError, "forbidden account operation"
    end
  end

  def amount
    self.balance + self.locked
  end

  def last_version
    versions.last
  end

  def examine
    versions = self.versions.o2n.load

    expected_amount = versions.reduce 0 do |expected, v|
      expected += v.amount_change
      return false if expected != v.amount
      expected
    end

    return expected_amount == self.amount
  end

  def trigger
    json = Jbuilder.encode do |json|
      json.(self, :balance, :locked, :currency)
    end
    member.trigger('account', json)
  end

  scope :locked_sum, -> (currency) { with_currency(currency).sum(:locked) }
  scope :balance_sum, -> (currency) { with_currency(currency).sum(:balance) }

  class AccountError < RuntimeError; end
  class LockedError < AccountError; end
  class BalanceError < AccountError; end
end
