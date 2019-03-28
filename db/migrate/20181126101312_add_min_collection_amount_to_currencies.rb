class AddMinCollectionAmountToCurrencies < ActiveRecord::Migration[4.2]
  def change
    add_column :currencies, :min_collection_amount, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :min_deposit_amount
  end
end
