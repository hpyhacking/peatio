class UpdateMarketsMinAmountAndPrice < ActiveRecord::Migration[5.2]
  def up
    Market.all do |m|
      # Set price and amount precision to max possible if precisions sum greater
      # then FUNDS_PRECISION.
      if m.amount_precision + m.price_precision > Market::FUNDS_PRECISION
        m.update_attribute(:price_precision, 6)
        m.update_attribute(:amount_precision, 6)
      end
      m.update_attribute(:min_amount, m.min_amount_by_precision)
      m.update_attribute(:min_price, m.min_price_by_precision)
    end
  end
end
