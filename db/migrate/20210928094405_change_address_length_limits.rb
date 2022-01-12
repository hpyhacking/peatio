class ChangeAddressLengthLimits < ActiveRecord::Migration[5.2]
  def up
    change_column :deposits, :address, :string, limit: 105
    change_column :withdraws, :rid, :string, limit: 105
    change_column :payment_addresses, :address, :string, limit: 105
  end

  def down
    change_column :deposits, :address, :string, limit: 95
    change_column :withdraws, :rid, :string, limit: 95
    change_column :payment_addresses, :address, :string, limit: 95
  end
end
