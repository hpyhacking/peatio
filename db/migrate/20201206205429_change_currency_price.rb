class ChangeCurrencyPrice < ActiveRecord::Migration[5.2]
  def up
    change_column :currencies, :price, :decimal, precision: 32, scale: 16, null: false, default: 1.0
  end

  def down
    change_column :currencies, :price, :decimal, precision: 32, scale: 16
  end
end
