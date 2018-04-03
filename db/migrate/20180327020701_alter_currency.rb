class AlterCurrency < ActiveRecord::Migration
  def change
    change_column :orders, :currency, :string, limit: 10
  end
end