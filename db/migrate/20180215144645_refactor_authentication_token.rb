# encoding: UTF-8
# frozen_string_literal: true

class RefactorAuthenticationToken < ActiveRecord::Migration
  def change
    change_column :authentications, :secret, :text
    rename_column :authentications, :secret, :token
  end
end
