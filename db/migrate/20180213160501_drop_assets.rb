# encoding: UTF-8
# frozen_string_literal: true

class DropAssets < ActiveRecord::Migration
  def change
    drop_table :assets
  end
end
