class AddDailyWithdrawLimitToCurrencies < ActiveRecord::Migration
  def change
    rename_column :currencies, :quick_withdraw_limit, :withdraw_limit_24h
    add_column :currencies, :withdraw_limit_72h, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :withdraw_limit_24h
  end
end
