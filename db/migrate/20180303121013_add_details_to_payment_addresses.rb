# encoding: UTF-8
# frozen_string_literal: true

class AddDetailsToPaymentAddresses < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :details, :string, limit: 1.kilobyte, null: false, default: '{}'
  end
end
