class DropUselessDepositState < ActiveRecord::Migration
  def change
    remove_column :deposits, :state
  end
end
