# encoding: UTF-8
# frozen_string_literal: true

class ImproveOrderModel2 < ActiveRecord::Migration
  def change
    add_index :orders, %i[type market_id]
    add_index :orders, %i[type member_id]
  end
end
