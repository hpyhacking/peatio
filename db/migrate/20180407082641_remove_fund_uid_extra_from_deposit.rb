# encoding: UTF-8
# frozen_string_literal: true

class RemoveFundUidExtraFromDeposit < ActiveRecord::Migration[4.2]
  def change
    remove_column :deposits, :fund_uid
    remove_column :deposits, :fund_extra
  end
end
