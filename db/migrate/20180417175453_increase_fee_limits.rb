# encoding: UTF-8
# frozen_string_literal: true

class IncreaseFeeLimits < ActiveRecord::Migration
  def change
    change_column :markets,    :ask_fee,      :decimal, null: false, default: 0, precision: 32, scale: 16
    change_column :markets,    :bid_fee,      :decimal, null: false, default: 0, precision: 32, scale: 16
    change_column :orders,     :fee,          :decimal, null: false, default: 0, precision: 32, scale: 16
    change_column :currencies, :withdraw_fee, :decimal, null: false, default: 0, precision: 32, scale: 16
  end
end
