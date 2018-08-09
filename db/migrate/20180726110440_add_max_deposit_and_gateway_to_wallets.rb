class AddMaxDepositAndGatewayToWallets < ActiveRecord::Migration
  def change
    add_column :wallets, :gateway,     :string,  limit: 1000, default: '{}', null: false,                           after: :nsig
    add_column :wallets, :max_balance, :decimal,              default: 0,    null: false, precision: 32, scale: 16, after: :gateway
  end
end
