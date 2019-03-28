# encoding: UTF-8
# frozen_string_literal: true

class AddBidToWithdraws < ActiveRecord::Migration[4.2]
  def change
    add_column :withdraws, :bid, :string, limit: 64
  end
end
