class UpdateMarketsMinAmountAndPrice < ActiveRecord::Migration[5.2]
  def change
    Market.find_each do |m|
      # Set price and amount precision to max possible if precisions sum greater
      # then FUNDS_PRECISION.
      attributes = {}
      if m.amount_precision + m.price_precision > Market::FUNDS_PRECISION
        attributes.merge!(price_precision: 6, amount_precision: 6)
      end
      attributes.merge!(min_amount: m.min_amount_by_precision,
                        min_price: m.min_price_by_precision)
      m.update_attributes(attributes)
    end
  end
end
