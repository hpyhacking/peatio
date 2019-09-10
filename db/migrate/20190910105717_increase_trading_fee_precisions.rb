class IncreaseTradingFeePrecisions < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        change_column :trading_fees, :maker, :decimal, precision: 7, scale: 6, default: 0, null: false
        change_column :trading_fees, :taker, :decimal, precision: 7, scale: 6, default: 0, null: false

        Market.find_each do |m|
          if m.amount_precision + m.price_precision > Market::FUNDS_PRECISION
            m.update_attribute(:price_precision, 5)
            m.update_attribute(:amount_precision, 5)
          end
        end
      end

      direction.down do
        change_column :trading_fees, :maker, :decimal, precision: 5, scale: 4, default: 0, null: false
        change_column :trading_fees, :taker, :decimal, precision: 5, scale: 4, default: 0, null: false
      end
    end
  end
end
