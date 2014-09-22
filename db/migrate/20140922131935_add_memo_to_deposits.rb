class AddMemoToDeposits < ActiveRecord::Migration
  def change
    add_column :withdraws, :memo, :string
  end
end
