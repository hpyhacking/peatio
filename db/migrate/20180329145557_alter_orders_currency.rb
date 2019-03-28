# encoding: UTF-8
# frozen_string_literal: true

class AlterOrdersCurrency < ActiveRecord::Migration[4.2]
  def change
    rename_column :orders, :currency, :market_id
  end
end
