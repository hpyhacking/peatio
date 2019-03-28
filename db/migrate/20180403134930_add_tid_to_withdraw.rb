# encoding: UTF-8
# frozen_string_literal: true

class AddTIDToWithdraw < ActiveRecord::Migration[4.2]
  def change
    add_column :withdraws, :tid, :string, limit: 64
    execute %{UPDATE withdraws SET tid = CONCAT('TID', id, currency_id, member_id) WHERE tid IS NULL}
    change_column :withdraws, :tid, :string, null: false, index: { unique: true }, limit: 64
  end
end
