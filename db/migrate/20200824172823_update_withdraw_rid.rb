class UpdateWithdrawRid < ActiveRecord::Migration[5.2]
  def change
    change_column :withdraws, :rid, :string, limit: 256, null: false
  end
end
