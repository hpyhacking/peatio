class RemoveSnFromWithdraw < ActiveRecord::Migration
  def change
    remove_column :withdraws, :sn
  end
end
