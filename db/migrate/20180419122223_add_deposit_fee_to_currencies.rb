# encoding: UTF-8
# frozen_string_literal: true

class AddDepositFeeToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :deposit_fee, :decimal, after: :type, null: false, default: 0, precision: 32, scale: 16
  end
end
