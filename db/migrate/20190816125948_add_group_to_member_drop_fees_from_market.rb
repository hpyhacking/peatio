class AddGroupToMemberDropFeesFromMarket < ActiveRecord::Migration[5.2]
  def up
    add_column :members, :group, :string, limit: 32, default: 'vip-0', null: false, after: :role
    Market.find_each do |m|
      TradingFee.new(market_id: m.id,
                     maker: m.maker_fee,
                     taker: m.taker_fee).save(validate: false)
    end
    remove_column :markets, :maker_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
    remove_column :markets, :taker_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
  end

  def down
    remove_column :members, :group
    add_column :markets, :maker_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
    add_column :markets, :taker_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
  end
end
