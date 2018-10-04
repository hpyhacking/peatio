class AddMinDepositAmountToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :min_deposit_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :quick_withdraw_limit
  end
end
