class ReplaceConfirmatioinsCountWithBlockHeader < ActiveRecord::Migration
  def change
    remove_column :deposits,  :confirmations
    remove_column :withdraws, :confirmations
    add_column :deposits,  :block_number, :integer, after: :aasm_state
    add_column :withdraws, :block_number, :integer, after: :aasm_state
  end
end
