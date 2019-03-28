# encoding: UTF-8
# frozen_string_literal: true

class AddDetailsToPaymentAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_addresses, :details, :string, limit: 1.kilobyte, null: false, default: '{}'
  end
end
