class AddDetailsToPaymentAddresses < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :details, :string, limit: 1.kilobyte, null: false, default: '{}'
  end
end
