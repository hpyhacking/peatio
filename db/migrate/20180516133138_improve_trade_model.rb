# encoding: UTF-8
# frozen_string_literal: true

class ImproveTradeModel < ActiveRecord::Migration
  def change
    change_column_null :trades, :price, false
    change_column_null :trades, :volume, false
    change_column_null :trades, :ask_id, false
    change_column_null :trades, :bid_id, false
    change_column_null :trades, :trend, false
    change_column_null :trades, :market_id, false
    change_column_null :trades, :created_at, false
    change_column_null :trades, :updated_at, false
    change_column_null :trades, :ask_member_id, false
    change_column_null :trades, :bid_member_id, false
    change_column_null :trades, :funds, false
    change_column :trades, :created_at, :datetime, after: :funds
    change_column :trades, :updated_at, :datetime, after: :created_at
    remove_index :trades, column: :ask_member_id
    remove_index :trades, column: :bid_member_id
    remove_index :trades, column: :created_at
    add_index :trades, [:market_id, :created_at]
    add_index :trades, [:ask_member_id, :bid_member_id]
  end
end
