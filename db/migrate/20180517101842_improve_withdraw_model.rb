# encoding: UTF-8
# frozen_string_literal: true

class ImproveWithdrawModel < ActiveRecord::Migration
  def change
    change_column_null :withdraws, :account_id, false
    change_column_null :withdraws, :member_id, false
    change_column_null :withdraws, :currency_id, false
    change_column_null :withdraws, :amount, false
    change_column_null :withdraws, :fee, false
    change_column :withdraws, :created_at, :datetime, after: :rid, null: false
    change_column :withdraws, :updated_at, :datetime, after: :created_at, null: false
    change_column :withdraws, :done_at, :datetime, after: :updated_at
    rename_column :withdraws, :done_at, :completed_at
    change_column_null :withdraws, :aasm_state, false
    change_column_null :withdraws, :type, false
    change_column :withdraws, :type, :string, limit: 30, null: false
    add_index :withdraws, :aasm_state
    add_index :withdraws, :account_id
    add_index :withdraws, :member_id
    add_index :withdraws, :type
    add_index :withdraws, :tid
    add_index :withdraws, %i[currency_id txid], unique: true
    change_column :withdraws, :aasm_state, :string, limit: 30, null: false
    change_column_default :withdraws, :sum, nil
  end
end
