# encoding: UTF-8
# frozen_string_literal: true

class AlterOrdersCurrency < ActiveRecord::Migration
  def change
    rename_column :orders, :currency, :market_id
  end
end
