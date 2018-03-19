class RemoveKeyFromCurrency < ActiveRecord::Migration
  def change
    remove_column :currencies, :key
  end
end
