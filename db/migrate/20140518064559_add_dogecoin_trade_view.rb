class AddDogecoinTradeView < ActiveRecord::Migration
  def up
    sql = Trade.with_currency(:dogcny, :dogbtc).
      where("ask_member_id <> bid_member_id").scoping do
      asks = Trade.select('created_at, volume, ask_member_id as member_id').to_sql
      bids = Trade.select('created_at, volume, bid_member_id as member_id').to_sql
      "#{asks} UNION #{bids}"
    end

    create_view :dogecoin_trades, sql
  end

  def down
    drop_view :dogecoin_trades
  end
end
