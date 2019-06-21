class AddRetriesToWithdraw < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :attempts, :integer, default: 0, null: false, after: :aasm_state
  end
end
