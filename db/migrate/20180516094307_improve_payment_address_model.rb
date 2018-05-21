# encoding: UTF-8
# frozen_string_literal: true

class ImprovePaymentAddressModel < ActiveRecord::Migration
  def change
    change_column :payment_addresses, :created_at, :datetime, null: false, after: :details
    change_column :payment_addresses, :updated_at, :datetime, null: false, after: :created_at
    change_column :payment_addresses, :secret, :string, null: true, limit: 128
    change_column :payment_addresses, :account_id, :integer, null: false
    change_column :payment_addresses, :currency_id, :integer, null: false, after: :id
    add_index :payment_addresses, :account_id, unique: true
    add_index :payment_addresses, [:currency_id, :address], unique: true
  end
end
