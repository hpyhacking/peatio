class Account < ActiveRecord::Base
  include Currencible

  FIX = :fix
  UNKNOWN = :unknown
  STRIKE_ADD = :strike_add
  STRIKE_SUB = :strike_sub
  STRIKE_FEE = :strike_fee
  STRIKE_UNLOCK = :strike_unlock
  ORDER_CANCEL = :order_cancel
  ORDER_SUBMIT = :order_submit
  ORDER_FULFILLED = :order_fulfilled
  WITHDRAW_LOCK = :withdraw_lock
  WITHDRAW_UNLOCK = :withdraw_unlock
  DEPOSIT = :deposit
  WITHDRAW = :withdraw
  ZERO = 0.to_d

  FUNS = {:unlock_funds => 1, :lock_funds => 2, :plus_funds => 3, :sub_funds => 4, :unlock_and_sub_funds => 5}

  belongs_to :member
  has_many :payment_addresses, -> { order(id: :asc) }
  has_many :versions, class_name: "::AccountVersion"
  has_many :partial_trees, -> { order(id: :desc) }

  validates :member_id, uniqueness: { scope: :currency }
  validates_numericality_of :balance, :locked, greater_than_or_equal_to: ZERO

  scope :enabled, -> { joins(:currency).merge(Currency.where(visible: true)) }

  after_commit :trigger, :sync_update

  def payment_address
    if currency.coin?
      payment_addresses.last || payment_addresses.create!(currency: currency)
    end
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
      raise ActiveRecord::RecordInvalid, account unless account.valid?
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
    expected = 0
    versions.find_each(batch_size: 100000) do |v|
      expected += v.amount_change
      return false if expected != v.amount
    end

    expected == self.amount
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
    self.class.connection.execute "update accounts set balance = balance + #{delta_b}, locked = locked + #{delta_l} where id = #{id}"
    add_to_transaction # so after_commit will be triggered
    self
  end

  scope :locked_sum, -> (currency) { with_currency(currency).sum(:locked) }
  scope :balance_sum, -> (currency) { with_currency(currency).sum(:balance) }

  class AccountError < RuntimeError; end
  class LockedError < AccountError; end
  class BalanceError < AccountError; end

  def as_json(*)
    super.merge! \
      deposit_address: payment_address&.deposit_address,
      currency:        currency.code
  end

  private

  def sync_update
    return unless member
    Pusher["private-#{member.sn}"].trigger_async 'accounts', {
      id:         id,
      type:       'update',
      attributes: { balance: balance, locked: locked }
    }
  end

end

# == Schema Information
# Schema version: 20180406080444
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  currency_id :integer
#  balance     :decimal(32, 16)
#  locked      :decimal(32, 16)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_accounts_on_currency_id                (currency_id)
#  index_accounts_on_member_id                  (member_id)
#  index_accounts_on_member_id_and_currency_id  (member_id,currency_id)
#
