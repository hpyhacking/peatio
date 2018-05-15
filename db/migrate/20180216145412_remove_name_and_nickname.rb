# encoding: UTF-8
# frozen_string_literal: true

class RemoveNameAndNickname < ActiveRecord::Migration
  def change
    remove_column :members, :nickname if column_exists?(:members, :nickname)
    remove_column :members, :name if column_exists?(:members, :name)
    remove_column :authentications, :nickname if column_exists?(:authentications, :nickname)
  end
end
