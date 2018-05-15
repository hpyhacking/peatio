# encoding: UTF-8
# frozen_string_literal: true

class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string  :ask_unit,      null: false, limit: 5,                 index: true
      t.string  :bid_unit,      null: false, limit: 5,                 index: true
      t.decimal :ask_fee,       null: false,            default: 0,    precision: 7, scale: 6
      t.decimal :bid_fee,       null: false,            default: 0,    precision: 7, scale: 6
      t.integer :ask_precision, null: false, limit: 1,  default: 4
      t.integer :bid_precision, null: false, limit: 1,  default: 4
      t.integer :position,      null: false,            default: 0,    index: true
      t.boolean :visible,       null: false,            default: true, index: true
      t.timestamps              null: false
    end

    change_column :markets, :id, :string, limit: 10

    add_index :markets, %i[ ask_unit bid_unit ], unique: true
  end
end
