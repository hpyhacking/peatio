class AddBlockchainKeyToWallet < ActiveRecord::Migration[4.2]
  def change
    add_column :wallets, :blockchain_key, :string, limit: 32, after: :id
  end
end
