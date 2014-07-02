class AddBalanceToProofs < ActiveRecord::Migration
  def change
    add_column :proofs, :balance, :string, limit: 30
  end
end
