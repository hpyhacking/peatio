# encoding: UTF-8
# frozen_string_literal: true

class AddFeeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :fee, :decimal, null: false, default: 0, precision: 7, scale: 6, after: :origin_volume
  end
end
