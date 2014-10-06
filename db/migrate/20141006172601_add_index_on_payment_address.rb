class AddIndexOnPaymentAddress < ActiveRecord::Migration
  def change
    add_index :payment_addresses, :address
  end
end
