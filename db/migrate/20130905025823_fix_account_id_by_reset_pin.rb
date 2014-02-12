class FixAccountIdByResetPin < ActiveRecord::Migration
  def change
    rename_column :reset_pins, :account_id, :member_id
  end
end
