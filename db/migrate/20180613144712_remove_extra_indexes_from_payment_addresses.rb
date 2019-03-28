class RemoveExtraIndexesFromPaymentAddresses < ActiveRecord::Migration[4.2]
  def change
    remove_index :payment_addresses, column: %i[account_id]
    remove_index :payment_addresses, column: %i[currency_id]
  end
end
