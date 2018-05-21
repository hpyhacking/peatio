# encoding: UTF-8
# frozen_string_literal: true

class ImproveAccountModel < ActiveRecord::Migration
  def change
    change_column :accounts, :member_id, :integer, null: false
    change_column :accounts, :currency_id, :integer, null: false
    change_column_null :accounts, :balance, false
    change_column_null :accounts, :locked, false
    change_column_null :accounts, :created_at, false
    change_column_null :accounts, :updated_at, false
    change_column_default :accounts, :balance, 0
    change_column_default :accounts, :locked, 0
    remove_index :accounts, column: %i[member_id currency_id]
    add_index :accounts, %i[currency_id member_id], unique: true
  end
end
