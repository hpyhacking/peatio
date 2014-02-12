class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.decimal :price, :precision => 32, :scale => 16
      t.decimal :volume, :precision => 32, :scale => 16
      t.integer :ask_id
      t.integer :bid_id
      t.boolean :trend # true: up or equal | false: down
      t.string  :currency
      t.timestamps
    end

    create_table :members_trades do |t|
      t.integer :member_id
      t.integer :trade_id
      t.timestamps
    end
  end
end
