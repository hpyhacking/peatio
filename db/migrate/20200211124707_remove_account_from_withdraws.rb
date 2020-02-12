class RemoveAccountFromWithdraws < ActiveRecord::Migration[5.2]
  def change
    remove_column :withdraws, :account_id
  end
end
