# encoding: UTF-8
# frozen_string_literal: true

class AddCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string  :key,                      limit: 30, null: false
      t.string  :code,                     limit: 30, null: false, index: { unique: true }
      t.string  :symbol,                   limit: 1,  null: false
      t.string  :type,                     limit: 30, null: false, default: 'coin'
      t.decimal :quick_withdraw_limit,     precision: 32, scale: 16, null: false, default: 0
      t.string  :options,                  limit: 1000, default: '{}', null: false
      t.boolean :visible,                  default: true, null: false, index: true
      t.integer :base_factor,              default: 1, null: false, limit: 8
      t.integer :precision,                limit: 1, default: 8, null: false
      t.timestamps                         null: false
    end
  end
end
