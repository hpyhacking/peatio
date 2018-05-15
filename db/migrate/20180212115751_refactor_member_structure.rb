# encoding: UTF-8
# frozen_string_literal: true

class RefactorMemberStructure < ActiveRecord::Migration
  def change
    change_column :members, :created_at, :datetime, null: false, after: :nickname
    change_column :members, :updated_at, :datetime, null: false, after: :created_at
    change_column :members, :sn, :string, null: false, limit: 14, index: true
    change_column :members, :email, :string, null: false, index: true
    change_column :members, :disabled, :boolean, null: false, default: false
    change_column :members, :api_disabled, :boolean, null: false, default: false
    change_column :members, :nickname, :string, null: true, limit: 32
    add_column    :members, :name, :string, null: true, limit: 45, after: :api_disabled
    add_column    :members, :level, :string, null: true, limit: 20, after: :id, default: ''
  end
end
