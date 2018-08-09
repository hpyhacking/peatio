class AddBlockchainKeyToWallet < ActiveRecord::Migration
  def change
    add_column :wallets, :blockchain_key, :string, limit: 32, after: :id
  end
end
