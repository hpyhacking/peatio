# frozen_string_literal: true

class AddMarketType < ActiveRecord::Migration[5.2]
  class LegacyMarket < ActiveRecord::Base
  end

  def up
    rename_table :markets, :legacy_markets

    create_table :markets do |t|
      t.string 'symbol', limit: 20, null: false
      t.string 'type', default: 'spot', null: false
      t.string 'base_unit', limit: 10, null: false
      t.string 'quote_unit', limit: 10, null: false
      t.bigint 'engine_id', null: false
      t.integer 'amount_precision', limit: 1, default: 4, null: false
      t.integer 'price_precision', limit: 1, default: 4, null: false
      t.decimal 'min_price', precision: 32, scale: 16, default: '0.0', null: false
      t.decimal 'max_price', precision: 32, scale: 16, default: '0.0', null: false
      t.decimal 'min_amount', precision: 32, scale: 16, default: '0.0', null: false
      t.integer 'position', null: false
      t.json 'data'
      t.string 'state', limit: 32, default: 'enabled', null: false
      t.timestamps
    end

    add_index(:markets, %i[base_unit quote_unit type], unique: true)
    add_index(:markets, %i[symbol type], unique: true)
    add_index(:markets, 'base_unit')
    add_index(:markets, 'position')
    add_index(:markets, 'quote_unit')
    add_index(:markets, 'engine_id')

    LegacyMarket.find_each do |market|
      market_attrs = market.attributes
      market_attrs['symbol'] = market_attrs['id']
      Market.create!(market_attrs.except('id', 'created_at', 'updated_at'))
    end

    drop_table :legacy_markets

    add_column(:orders, :market_type, :string, null: false, default: 'spot', after: 'market_id')
    remove_index(:orders, %w[type market_id]) if index_exists?(:orders, %w[type market_id])
    remove_index(:orders, %w[type state market_id]) if index_exists?(:orders, %w[type state market_id])
    add_index(:orders, %w[type market_id market_type]) unless index_exists?(:orders, %w[type market_id market_type])
    add_index(:orders, %w[type state market_id market_type]) unless index_exists?(:orders, %w[type state market_id market_type])


    add_column(:trades, :market_type, :string, null: false, default: 'spot', after: 'market_id')
    remove_index(:trades, 'maker_id') if index_exists?(:trades, 'market_id')
    remove_index(:trades, 'taker_id') if index_exists?(:trades, 'taker_id')
    remove_index(:trades, %w[market_id created_at]) if index_exists?(:trades, %w[market_id created_at])
    add_index(:trades, %w[maker_id market_type]) unless index_exists?(:trades, %w[maker_id market_type])
    add_index(:trades, %w[taker_id market_type]) unless index_exists?(:trades, %w[taker_id market_type])
    add_index(:trades, %w[maker_id market_type created_at]) unless index_exists?(:trades, %w[maker_id market_type created_at])


    add_column(:trading_fees, :market_type, :string, null: false, default: 'spot', after: 'market_id')
    remove_index(:trading_fees, %w[market_id group]) if index_exists?(:trading_fees, %w[market_id group])
    remove_index(:trading_fees, 'market_id') if index_exists?(:trading_fees, 'market_id')
    add_index(:trading_fees, %w[market_id market_type group], unique: true) unless index_exists?(:trading_fees, %w[market_id market_type group])
    add_index(:trading_fees, %w[market_id market_type]) unless index_exists?(:trading_fees, %w[market_id market_type])
  end

  def down
    rename_table :markets, :legacy_markets

    create_table :markets do |t|
      t.string 'base_unit', limit: 10, null: false
      t.string 'quote_unit', limit: 10, null: false
      t.bigint 'engine_id', null: false
      t.integer 'amount_precision', limit: 1, default: 4, null: false
      t.integer 'price_precision', limit: 1, default: 4, null: false
      t.decimal 'min_price', precision: 32, scale: 16, default: '0.0', null: false
      t.decimal 'max_price', precision: 32, scale: 16, default: '0.0', null: false
      t.decimal 'min_amount', precision: 32, scale: 16, default: '0.0', null: false
      t.integer 'position', null: false
      t.json 'data'
      t.string 'state', limit: 32, default: 'enabled', null: false
      t.timestamps
    end

    change_column :markets, :id, :string, limit: 20

    add_index(:markets, %i[base_unit quote_unit], unique: true)
    add_index(:markets, 'id', unique: true)
    add_index(:markets, 'base_unit')
    add_index(:markets, 'position')
    add_index(:markets, 'quote_unit')
    add_index(:markets, 'engine_id')

    LegacyMarket.find_each do |market|
      if market.type == 'qe'
        market.destroy!
        next
      end

      market_attrs = market.attributes
      market_attrs['id'] = market_attrs['symbol']
      Market.create!(market_attrs.except('type', 'created_at', 'updated_at'))
    end

    drop_table :legacy_markets

    Order.where(market_type: 'qe').delete_all
    remove_index(:orders, %w[type market_id market_type]) if index_exists?(:orders, %w[type market_id market_type])
    remove_index(:orders, %w[type state market_id market_type]) if index_exists?(:orders, %w[type state market_id market_type])
    add_index(:orders, %w[type market_id]) unless index_exists?(:orders, %w[type market_id])
    add_index(:orders, %w[type state market_id]) unless index_exists?(:orders, %w[type state market_id])
    remove_column(:orders, :market_type)

    Trade.where(market_type: 'qe').delete_all
    remove_index(:trades, %w[maker_id market_type]) if index_exists?(:trades, %w[maker_id market_type])
    remove_index(:trades, %w[taker_id market_type]) if index_exists?(:trades, %w[taker_id market_type])
    remove_index(:trades, %w[maker_id market_type created_at]) if index_exists?(:trades, %w[maker_id market_type created_at])
    add_index(:trades, 'maker_id') unless index_exists?(:trades, 'market_id')
    add_index(:trades, 'taker_id') unless index_exists?(:trades, 'taker_id')
    add_index(:trades, %w[market_id created_at]) unless index_exists?(:trades, %w[market_id created_at])
    remove_column(:trades, :market_type)

    TradingFee.where(market_type: 'qe').delete_all
    remove_index(:trading_fees, %w[market_id market_type group]) if index_exists?(:trading_fees, %w[market_id market_type group])
    remove_index(:trading_fees, %w[market_id market_type]) if index_exists?(:trading_fees, %w[market_id market_type])
    add_index(:trading_fees, %w[market_id group]) unless index_exists?(:trading_fees, %w[market_id group])
    add_index(:trading_fees, 'market_id') unless index_exists?(:trading_fees, 'market_id')
    remove_column(:trading_fees, :market_type, :string, null: false, default: 'spot', after: 'market_id')
  end
end
