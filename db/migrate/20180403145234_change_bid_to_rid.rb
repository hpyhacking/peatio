class ChangeBidToRid < ActiveRecord::Migration
  def change
    rename_column :withdraws, :bid, :rid
  end
end
