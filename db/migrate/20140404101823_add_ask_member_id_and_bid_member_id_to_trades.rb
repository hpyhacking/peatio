class AddAskMemberIdAndBidMemberIdToTrades < ActiveRecord::Migration
  def change
    add_column :trades, :ask_member_id, :integer
    add_column :trades, :bid_member_id, :integer

    add_index :trades, :ask_member_id
    add_index :trades, :bid_member_id
  end
end
