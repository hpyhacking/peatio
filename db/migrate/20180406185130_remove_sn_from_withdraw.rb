# encoding: UTF-8
# frozen_string_literal: true

class RemoveSnFromWithdraw < ActiveRecord::Migration
  def change
    remove_column :withdraws, :sn
  end
end
