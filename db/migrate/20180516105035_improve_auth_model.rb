# encoding: UTF-8
# frozen_string_literal: true

class ImproveAuthModel < ActiveRecord::Migration
  def change
    change_column :authentications, :provider, :string, null: false, limit: 30
    change_column :authentications, :uid, :string, null: false, limit: 255
    change_column :authentications, :token, :string, null: true, limit: 1024
    change_column :authentications, :member_id, :integer, null: false
    change_column :authentications, :created_at, :datetime, null: false
    change_column :authentications, :updated_at, :datetime, null: false
    remove_index :authentications, column: %i[provider uid]
    add_index :authentications, %i[provider uid], unique: true
    add_index :authentications, %i[provider member_id], unique: true
  end
end
