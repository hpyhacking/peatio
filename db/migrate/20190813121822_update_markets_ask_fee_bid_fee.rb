class UpdateMarketsAskFeeBidFee < ActiveRecord::Migration[5.2]
  def up
    rename_column :markets, :ask_fee, :maker_fee if column_exists?(:markets, :ask_fee)
    rename_column :markets, :bid_fee, :taker_fee if column_exists?(:markets, :bid_fee)
    rename_column :trades, :ask_id, :maker_order_id if column_exists?(:trades, :ask_id)
    rename_column :trades, :bid_id, :taker_order_id if column_exists?(:trades, :bid_id)
    rename_column :trades, :ask_member_id, :maker_id if column_exists?(:trades, :ask_member_id)
    rename_column :trades, :bid_member_id, :taker_id if column_exists?(:trades, :bid_member_id)
    rename_column :trades, :volume, :amount if column_exists?(:trades, :volume)
    if column_exists?(:trades, :funds)
      change_column :trades, :funds, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :amount
      rename_column :trades, :funds, :total
    end
    remove_column :trades, :trend if column_exists?(:trades, :trend)
    if column_exists?(:orders, :fee)
      change_column :orders, :fee, :decimal, null: false, default: 0, precision: 17, scale: 16
      rename_column :orders, :fee, :maker_fee
    end
    add_column :orders, :taker_fee, :decimal, null: false, default: 0, precision: 17, scale: 16, after: :maker_fee

    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute('UPDATE orders SET orders.taker_fee = orders.maker_fee')
      execute('UPDATE trades SET
              trades.maker_order_id = trades.maker_order_id + trades.taker_order_id,
              trades.taker_order_id = trades.maker_order_id - trades.taker_order_id,
              trades.maker_order_id = trades.maker_order_id - trades.taker_order_id
              WHERE (trades.maker_order_id > trades.taker_order_id)')

    when 'PostgreSQL'
      execute('UPDATE "orders" SET "taker_fee" = "maker_fee"')
      execute('UPDATE "trades" SET
              "maker_order_id" = "taker_order_id",
              "taker_order_id" = "maker_order_id"
              WHERE ("maker_order_id" > "taker_order_id")')

    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end

  end

  def down
    rename_column :markets, :maker_fee, :ask_fee if column_exists?(:markets, :maker_fee)
    rename_column :markets, :taker_fee, :bid_fee if column_exists?(:markets, :taker_fee)
    if column_exists?(:trades, :total)
      change_column :trades, :total, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :taker_id
      rename_column :trades, :total, :funds
    end
    if column_exists?(:orders, :maker_fee)
      change_column :orders, :maker_fee, :decimal, null: false, default: 0, precision: 32, scale: 16
      rename_column :orders, :maker_fee, :fee
    end
    remove_column :orders, :taker_fee
    rename_column :trades, :maker_order_id, :ask_id if column_exists?(:trades, :maker_order_id)
    rename_column :trades, :taker_order_id, :bid_id if column_exists?(:trades, :taker_order_id)
    rename_column :trades, :maker_id, :ask_member_id if column_exists?(:trades, :maker_id)
    rename_column :trades, :taker_id, :bid_member_id if column_exists?(:trades, :taker_id)
    rename_column :trades, :amount, :volume if column_exists?(:trades, :volume)
    rename_column :trades, :total, :funds if column_exists?(:trades, :total)
    add_column :trades, :trend, :integer, null: false
  end
end
