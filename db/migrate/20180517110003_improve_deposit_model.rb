# encoding: UTF-8
# frozen_string_literal: true

class ImproveDepositModel < ActiveRecord::Migration
  def change
    change_column :deposits, :aasm_state, :string, limit: 30, null: false
    add_index :deposits, %i[member_id txid]
    add_index :deposits, %i[aasm_state member_id currency_id]
    add_index :deposits, :tid
  end
end
