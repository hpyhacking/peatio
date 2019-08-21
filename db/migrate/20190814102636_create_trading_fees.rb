class CreateTradingFees < ActiveRecord::Migration[5.2]
  def change
    create_table :trading_fees do |t|

      t.string :market_id, limit: 20, default: 'any', null: false, index: true, foreign_key: true
      t.string :group, limit: 32, default: 'any', null: false, index: true

      t.decimal :maker, precision: 5, scale: 4, default: 0, null: false
      t.decimal :taker, precision: 5, scale: 4, default: 0, null: false

      t.timestamps
    end

    add_index :trading_fees, %i[market_id group], unique: true
  end
end
