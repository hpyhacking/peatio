class RemoveNsigParentFromWallets < ActiveRecord::Migration[5.2]
  def change
    remove_column :wallets, :nsig
    remove_column :wallets, :parent
  end
end
