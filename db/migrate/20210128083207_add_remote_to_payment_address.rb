class AddRemoteToPaymentAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_addresses, :remote, :boolean, default: false, null: false, after: :address
  end
end
