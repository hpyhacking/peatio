# encoding: UTF-8
# frozen_string_literal: true

class RemoveKeyFromCurrency < ActiveRecord::Migration
  def change
    remove_column :currencies, :key
  end
end
