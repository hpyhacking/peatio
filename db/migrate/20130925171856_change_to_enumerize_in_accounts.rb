class ChangeToEnumerizeInAccounts < ActiveRecord::Migration
  def up
    change_column :accounts, :currency, :integer
  end

  def down
    change_column :accounts, :currency, :string
  end
end
