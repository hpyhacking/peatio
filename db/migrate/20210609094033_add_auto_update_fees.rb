class AddAutoUpdateFees < ActiveRecord::Migration[5.2]
  def change
    add_column :blockchains, :min_deposit_amount, :decimal, precision: 32, scale: 16, default: 0, null: false, after: :min_confirmations
    add_column :blockchains, :withdraw_fee, :decimal, precision: 32, scale: 16, default: 0, null: false, after: :min_deposit_amount
    add_column :blockchains, :min_withdraw_amount, :decimal, precision: 32, scale: 16, default: 0, null: false, after: :withdraw_fee

    add_column :blockchain_currencies, :auto_update_fees_enabled, :boolean, default: true, null: false, after: :withdrawal_enabled
  end
end
