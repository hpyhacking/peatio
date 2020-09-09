class RemoveDefaultPositionValueFromCurrenciesAndMarkets < ActiveRecord::Migration[5.2]
  def up
    change_column :currencies, :position, :integer, default: nil
    change_column :markets, :position, :integer, default: nil

    # Update currency/market positions for already existed items
    Currency.order(:position, :updated_at).each.with_index(1) do |currency, index|
      currency.update_column(:position, index)
    end

    Market.order(:position, :updated_at).each.with_index(1) do |market, index|
      market.update_column(:position, index)
    end
  end

  def down
    change_column :currencies, :position, :integer, default: 0
    change_column :markets, :position, :integer, default: 0
  end
end
