# encoding: UTF-8
# frozen_string_literal: true

class MakeSerialNumberUnique < ActiveRecord::Migration
  def change
    remove_index :members, :sn if index_exists?(:members, :sn)
    add_index :members, :sn, unique: true
  end
end
