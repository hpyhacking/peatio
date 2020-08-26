class AddTransferTypeInDepostWithdraw < ActiveRecord::Migration[5.2]
  def up
    add_column :deposits, :transfer_type, :integer, after: :type unless column_exists?(:deposits, :transfer_type)
    add_column :withdraws, :transfer_type, :integer, after: :type unless column_exists?(:withdraws, :transfer_type)
  end

  def down
    remove_column :deposits, :transfer_type if column_exists?(:deposits, :transfer_type)
    remove_column :withdraws, :transfer_type if column_exists?(:withdraws, :transfer_type)
  end
end
