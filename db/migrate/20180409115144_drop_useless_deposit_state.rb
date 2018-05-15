# encoding: UTF-8
# frozen_string_literal: true

class DropUselessDepositState < ActiveRecord::Migration
  def change
    remove_column :deposits, :state
  end
end
