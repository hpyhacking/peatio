class AddSecretToPaymentAddress < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :secret, :string
  end
end
