class AddAskMemberSnAndBidMemberSnToTrades < ActiveRecord::Migration
  def change
    add_column :trades, :ask_member_sn, :string
    add_column :trades, :bid_member_sn, :string

    add_index :members, :sn
  end
end
