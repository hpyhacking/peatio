class DropRunningAccounts < ActiveRecord::Migration
  def change
    drop_table :running_accounts
  end
end
