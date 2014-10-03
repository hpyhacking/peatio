class AddTxoutToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :txout, :integer
    add_index :deposits, [:txid, :txout]
  end
end
