class AccountVersion < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  HISTORY = [Account::STRIKE_ADD, Account::STRIKE_SUB, Account::STRIKE_FEE, Account::DEPOSIT, Account::WITHDRAW, Account::FIX]

  enumerize :fun, in: Account::FUNS

  enumerize :reason, in: {
    Account::UNKNOWN => 0,
    Account::FIX => 1,
    Account::STRIKE_FEE => 100,
    Account::STRIKE_ADD => 110,
    Account::STRIKE_SUB => 120,
    Account::STRIKE_UNLOCK => 130,
    Account::ORDER_SUBMIT => 600,
    Account::ORDER_CANCEL => 610,
    Account::WITHDRAW_LOCK => 800,
    Account::WITHDRAW_UNLOCK => 810,
    Account::DEPOSIT => 1000,
    Account::WITHDRAW => 2000
  }, scope: true

  belongs_to :account
  belongs_to :modifiable, polymorphic: true

  scope :history, -> { with_reason(*HISTORY).reverse_order }
  scope :o2n, -> { order('id asc') }

  def detail_template
    if self.detail.nil? || self.detail.empty?
      return ["system", {}] 
    end

    [self.detail.delete(:tmp) || "default", self.detail || {}]
  end

  def amount_change
    balance + locked
  end

  def modify_amount
    @modify_amount ||= self.locked + self.balance
  end

  def in
    modify_amount > 0 ? modify_amount : nil
  end

  def out
    modify_amount < 0 ? modify_amount : nil
  end

  alias :template :detail_template
end
