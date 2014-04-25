class AddIndexOnAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, [:member_id, :currency]
    add_index :accounts, :member_id
  end
end
