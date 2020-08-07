class AddWalletBalance < ActiveRecord::Migration[5.2]
  def change
    add_column :wallets, :balance, :json, after: :settings_encrypted
  end
end
