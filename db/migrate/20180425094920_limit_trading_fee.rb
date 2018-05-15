# encoding: UTF-8
# frozen_string_literal: true

class LimitTradingFee < ActiveRecord::Migration
  def change
    execute %{UPDATE markets SET ask_fee = 0.5 WHERE ask_fee > 0.5}
    execute %{UPDATE markets SET bid_fee = 0.5 WHERE bid_fee > 0.5}
    change_column :markets, :ask_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
    change_column :markets, :bid_fee, :decimal, null: false, default: 0, precision: 17, scale: 16
  end
end
