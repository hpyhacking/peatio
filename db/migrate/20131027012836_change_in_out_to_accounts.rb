class ChangeInOutToAccounts < ActiveRecord::Migration
  def up
    change_column :accounts, :in, :decimal, :precision => 32, :scale => 16
    change_column :accounts, :out, :decimal, :precision => 32, :scale => 16
  end

  def down
    change_column :accounts, :in, :decimal, :precision => 32, :scale => 16
    change_column :accounts, :out, :decimal, :precision => 32, :scale => 16
  end
end
