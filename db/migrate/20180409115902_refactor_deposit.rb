# encoding: UTF-8
# frozen_string_literal: true

class RefactorDeposit < ActiveRecord::Migration
  def change
    change_column_null :deposits, :account_id, false
    change_column_null :deposits, :member_id, false
    change_column_null :deposits, :currency_id, false
    change_column_null :deposits, :amount, false
    change_column_null :deposits, :fee, false
    change_column_null :deposits, :aasm_state, false
    change_column_null :deposits, :created_at, false
    change_column_null :deposits, :updated_at, false
    add_column :deposits, :new_confirmations, :integer, null: false, default: 0, after: :confirmations
    execute "UPDATE deposits SET new_confirmations = confirmations WHERE confirmations IS NOT NULL"
    remove_column :deposits, :confirmations
    rename_column :deposits, :new_confirmations, :confirmations
    change_column :deposits, :type, :string, null: false, limit: 30
    add_index :deposits, :type
    change_column :deposits, :txid, :string, null: true, limit: 128
    change_column :deposits, :created_at, :datetime, null: false, after: :tid
    change_column :deposits, :updated_at, :datetime, null: false, after: :created_at
    change_column :deposits, :done_at, :datetime, after: :updated_at
    remove_column :deposits, :account_id
    change_column :deposits, :txout, :integer, after: :txid
    remove_index :deposits, column: %i[txid txout]
    add_column :deposits, :address, :string, after: :fee, index: true, limit: 64
    add_index :deposits, %i[currency_id txid txout], unique: true
    remove_column :deposits, :payment_transaction_id
    rename_column :deposits, :done_at, :completed_at
    drop_table :payment_transactions
  end
end
