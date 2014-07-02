class AddBalanceToProofs < ActiveRecord::Migration
  def change
    add_column :proofs, :balance, :decimal
  end
end
