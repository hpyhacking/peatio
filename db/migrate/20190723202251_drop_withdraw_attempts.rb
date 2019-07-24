class DropWithdrawAttempts < ActiveRecord::Migration[5.2]
  def up
    remove_column :withdraws, :attempts
  end

  def down
    add_column :withdraws, :attempts, :integer, default: 0, null: false, after: :aasm_state
  end
end
