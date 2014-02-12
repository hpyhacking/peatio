class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :bid
      t.string :ask
      t.string :currency
      t.decimal :price, :precision => 32, :scale => 16
      t.decimal :volume, :precision => 32, :scale => 16
      t.decimal :origin_volume, :precision => 32, :scale => 16
      t.string :state
      t.datetime :done_at
      t.string :type
      t.integer :member_id
      t.timestamps
    end
  end
end
