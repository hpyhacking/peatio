# encoding: UTF-8
# frozen_string_literal: true

class DropAPITokens < ActiveRecord::Migration
  def change
    drop_table :api_tokens
  end
end
