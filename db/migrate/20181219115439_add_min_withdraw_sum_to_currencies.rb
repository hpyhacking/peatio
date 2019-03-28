class AddMinWithdrawSumToCurrencies < ActiveRecord::Migration[4.2]
  def change
    add_column :currencies, :min_withdraw_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :min_collection_amount
    change_column :currencies, :min_deposit_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :deposit_fee
    change_column :currencies, :min_collection_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :min_deposit_amount
    change_column :currencies, :withdraw_fee, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :min_collection_amount
    change_column :currencies, :min_withdraw_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :withdraw_fee
  end
end
