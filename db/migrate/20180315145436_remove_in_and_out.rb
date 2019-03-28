# encoding: UTF-8
# frozen_string_literal: true

class RemoveInAndOut < ActiveRecord::Migration[4.2]
  def change
    remove_columns :accounts, :in, :out
  end
end
