# encoding: UTF-8
# frozen_string_literal: true

class ImproveOrderModel < ActiveRecord::Migration
  def change
    remove_columns :orders, :sn, :done_at, :source
    execute %[DELETE FROM orders WHERE ask IS NULL OR bid IS NULL]
    change_column :orders, :bid, :integer, null: false
    change_column :orders, :ask, :integer, null: false
    change_column :orders, :market_id, :string, null: false, limit: 10
    change_column_null :orders, :volume, false
    change_column_null :orders, :origin_volume, false
    change_column_null :orders, :state, false
    change_column_null :orders, :type, false
    change_column_null :orders, :member_id, false
    change_column :orders, :created_at, :datetime, null: false, after: :trades_count
    change_column :orders, :updated_at, :datetime, null: false, after: :created_at
    change_column :orders, :ord_type, :string, null: false, limit: 30
    change_column_null :orders, :locked, false
    change_column_null :orders, :origin_locked, false
    change_column_null :orders, :trades_count, false
    change_column_default :orders, :locked, 0
    change_column_default :orders, :origin_locked, 0
    remove_index :orders, column: %i[market_id state]
    remove_index :orders, column: %i[member_id state]
    add_index :orders, %i[type state member_id]
    add_index :orders, %i[type state market_id]
  end
end
