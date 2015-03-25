class FixPaymentAddressCurrency < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :currency, :integer
  end
end
