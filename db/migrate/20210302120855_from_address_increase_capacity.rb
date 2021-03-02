class FromAddressIncreaseCapacity < ActiveRecord::Migration[5.2]
  def change
    change_column :deposits, :from_addresses, :text, after: :address
  end
end
