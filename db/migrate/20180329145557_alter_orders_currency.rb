class AlterOrdersCurrency < ActiveRecord::Migration
  def change
    rename_column :orders, :currency, :market_id
  end
end