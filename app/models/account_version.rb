class AccountVersion < ActiveRecord::Base
  extend Enumerize
  include Currencible

  HISTORY = [Account::STRIKE_ADD, Account::STRIKE_SUB, Account::STRIKE_FEE, Account::DEPOSIT, Account::WITHDRAW, Account::FIX]

  enumerize :fun, in: Account::FUNS

  REASON_CODES = {
    Account::UNKNOWN => 0,
    Account::FIX => 1,
    Account::STRIKE_FEE => 100,
    Account::STRIKE_ADD => 110,
    Account::STRIKE_SUB => 120,
    Account::STRIKE_UNLOCK => 130,
    Account::ORDER_SUBMIT => 600,
    Account::ORDER_CANCEL => 610,
    Account::ORDER_FULFILLED => 620,
    Account::WITHDRAW_LOCK => 800,
    Account::WITHDRAW_UNLOCK => 810,
    Account::DEPOSIT => 1000,
    Account::WITHDRAW => 2000 }
  enumerize :reason, in: REASON_CODES, scope: true

  belongs_to :account
  belongs_to :modifiable, polymorphic: true

  scope :history, -> { with_reason(*HISTORY).reverse_order }

  # Use account balance and locked columns as optimistic lock column. If the
  # passed in balance and locked doesn't match associated account's data in
  # database, exception raise. Otherwise the AccountVersion record will be
  # created.
  #
  # TODO: find a more generic way to construct the sql
  def self.optimistically_lock_account_and_create!(balance, locked, attrs)
    attrs = attrs.symbolize_keys
    attrs[:created_at]  = Time.now
    attrs[:updated_at]  = attrs[:created_at]
    attrs[:fun]         = Account::FUNS[attrs[:fun]]
    attrs[:reason]      = REASON_CODES[attrs[:reason]]
    attrs[:currency_id] = attrs.delete(:currency).id

    account_id = attrs[:account_id]
    raise ActiveRecord::ActiveRecordError, "account must be specified" unless account_id.present?

    qmarks       = (['?']*attrs.size).join(',')
    values_array = [qmarks, *attrs.values]
    values       = sanitize_sql_array(values_array)

    columns = attrs.keys.map { |k| connection.quote_column_name(k) }.join(', ')
    select  = Account.unscoped.select(values).where(id: account_id, balance: balance, locked: locked).to_sql
    stmt    = "INSERT INTO account_versions (#{columns}) #{select}"

    # Dmytro LitsLink notes on PostgreSQL 10.2:
    #
    # 1. ActiveRecord::ConnectionAdapters::DatabaseStatements#insert 
    #    returns nil if account version can't be created.
    # 2. Need to specify primary key column name explicitly 
    #    to produce sql with `RETURNING "id"` at the end of the `INSERT` SQL statement.
    #
    # MSSQL notes:
    #
    # 1. ActiveRecord::ConnectionAdapters::DatabaseStatements#insert returns nil too.
    #
    connection.insert(stmt, nil, 'id').tap do |id|
      if id == 0 || id.nil?
        record = new attrs
        raise ActiveRecord::StaleObjectError.new(record, "create")
      end
    end
  end

  def detail_template
    if self.detail.nil? || self.detail.empty?
      return ["system", {}]
    end

    [self.detail.delete(:tmp) || "default", self.detail || {}]
  end

  def amount_change
    balance + locked
  end

  def in
    amount_change > 0 ? amount_change : nil
  end

   def out
    amount_change < 0 ? amount_change : nil
  end

  alias :template :detail_template
end

# == Schema Information
# Schema version: 20180227163417
#
# Table name: account_versions
#
#  id              :integer          not null, primary key
#  member_id       :integer
#  account_id      :integer
#  reason          :integer
#  balance         :decimal(32, 16)
#  locked          :decimal(32, 16)
#  fee             :decimal(32, 16)
#  amount          :decimal(32, 16)
#  modifiable_id   :integer
#  modifiable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  currency_id     :integer
#  fun             :integer
#
# Indexes
#
#  index_account_versions_on_account_id                         (account_id)
#  index_account_versions_on_account_id_and_reason              (account_id,reason)
#  index_account_versions_on_currency_id                        (currency_id)
#  index_account_versions_on_member_id_and_reason               (member_id,reason)
#  index_account_versions_on_modifiable_id_and_modifiable_type  (modifiable_id,modifiable_type)
#
