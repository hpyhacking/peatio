class AddTIDToWithdraw < ActiveRecord::Migration
  def change
    add_column :withdraws, :tid, :string, limit: 64
    execute %{UPDATE withdraws SET tid = CONCAT('TID', id, currency_id, member_id) WHERE tid IS NULL}
    change_column :withdraws, :tid, :string, null: false, index: { unique: true }, limit: 64
  end
end
