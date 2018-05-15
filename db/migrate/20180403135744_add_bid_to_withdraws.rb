# encoding: UTF-8
# frozen_string_literal: true

class AddBidToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :bid, :string, limit: 64
  end
end
