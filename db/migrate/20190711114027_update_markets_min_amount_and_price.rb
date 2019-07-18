class UpdateMarketsMinAmountAndPrice < ActiveRecord::Migration[5.2]
  def change
    Market.find_each do |m|
      # Set price and amount precision to max possible if precisions sum greater
      # then FUNDS_PRECISION.
      if m.amount_precision + m.price_precision > Market::FUNDS_PRECISION
        m.price_precision = m.amount_precision = 6
      end
      m.min_amount = m.min_amount_by_precision
      m.min_price = m.min_price_by_precision
      m.save!
    end
  end
end
