class AddFromAddressesToDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :deposits, :from_addresses, :string, limit: 1000, after: :address
  end
end
