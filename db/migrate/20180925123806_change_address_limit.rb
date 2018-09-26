class ChangeAddressLimit < ActiveRecord::Migration
  def change
    change_column :deposits, :address, :string, limit: 95
    change_column :withdraws, :rid, :string, limit: 95
    change_column :payment_addresses, :address, :string, limit: 95
  end
end
