# encoding: UTF-8
# frozen_string_literal: true

class ImproveMemberModel < ActiveRecord::Migration
  def change
    add_index :members, :email, unique: true
    add_index :members, :disabled
  end
end
