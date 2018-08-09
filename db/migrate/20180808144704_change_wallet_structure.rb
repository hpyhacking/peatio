class ChangeWalletStructure < ActiveRecord::Migration
  def change
    change_column :wallets, :gateway, :string, limit: 20, default: '', null: false
    add_column :wallets, :settings, :string,
               limit: 1000, default: '{}', null: false, after: :gateway
  end
end
