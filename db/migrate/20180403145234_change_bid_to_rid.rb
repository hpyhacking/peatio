# encoding: UTF-8
# frozen_string_literal: true

class ChangeBidToRid < ActiveRecord::Migration
  def change
    rename_column :withdraws, :bid, :rid
  end
end
