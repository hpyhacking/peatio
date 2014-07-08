# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  currency   :integer
#  balance    :decimal(32, 16)
#  locked     :decimal(32, 16)
#  created_at :datetime
#  updated_at :datetime
#  in         :decimal(32, 16)
#  out        :decimal(32, 16)
#

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
  ORDER_FULLFILLED = :order_fullfilled
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
    payment_addresses.last || payment_addresses.create(currency: self.currency)
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
    change_balance_and_locked amount, 0
  end

  def sub_funds(amount, fee: ZERO, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.balance) and raise AccountError, "cannot subtract funds (amount: #{amount})"
    change_balance_and_locked -amount, 0
  end

  def lock_funds(amount, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.balance) and raise AccountError, "cannot lock funds (amount: #{amount})"
    change_balance_and_locked -amount, amount
  end

  def unlock_funds(amount, reason: nil, ref: nil)
    (amount <= ZERO or amount > self.locked) and raise AccountError, "cannot unlock funds (amount: #{amount})"
    change_balance_and_locked amount, -amount
  end

  def unlock_and_sub_funds(amount, locked: ZERO, fee: ZERO, reason: nil, ref: nil)
    raise AccountError, "cannot unlock and subtract funds (amount: #{amount})" if ((amount <= 0) or (amount > locked))
    raise LockedError, "invalid lock amount" unless locked
    raise LockedError, "invalid lock amount (amount: #{amount}, locked: #{locked}, self.locked: #{self.locked})" if ((locked <= 0) or (locked > self.locked))
    change_balance_and_locked locked-amount, -locked
  end

  after(*FUNS.keys) do |account, fun, changed, opts|
    begin
      opts ||= {}
      fee = opts[:fee] || ZERO
      reason = opts[:reason] || Account::UNKNOWN

      attributes = { fun: fun,
                     fee: fee,
                     reason: reason,
                     amount: account.amount,
                     currency: account.currency,
                     member_id: account.member_id,
                     account_id: account.id }

      if opts[:ref] and opts[:ref].respond_to?(:id)
        ref_klass = opts[:ref].class
        attributes.merge! \
          modifiable_id: opts[:ref].id,
          modifiable_type: ref_klass.respond_to?(:base_class) ? ref_klass.base_class.name : ref_klass.name
      end

      locked, balance = compute_locked_and_balance(fun, changed, opts)
      attributes.merge! locked: locked, balance: balance

      AccountVersion.optimistically_lock_account_and_create!(account.balance, account.locked, attributes)
    rescue ActiveRecord::StaleObjectError
      Rails.logger.info "Stale account##{account.id} found when create associated account version, retry."
      account = Account.find(account.id)
      retry
    end
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
    expected_amount = versions.order(:id).reduce(0) do |expected, v|
      expected += v.amount_change
      return false if expected != v.amount
      expected
    end

    return expected_amount == self.amount
  end

  def trigger
    return unless member

    json = Jbuilder.encode do |json|
      json.(self, :balance, :locked, :currency)
    end
    member.trigger('account', json)
  end

  def change_balance_and_locked(delta_b, delta_l)
    self.balance += delta_b
    self.locked  += delta_l
    ActiveRecord::Base.connection.execute "update accounts set balance = balance + #{delta_b}, locked = locked + #{delta_l} where id = #{id}"
    self
  end

  scope :locked_sum, -> (currency) { with_currency(currency).sum(:locked) }
  scope :balance_sum, -> (currency) { with_currency(currency).sum(:balance) }

  class AccountError < RuntimeError; end
  class LockedError < AccountError; end
  class BalanceError < AccountError; end
end
