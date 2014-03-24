class AddAasmStateToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :aasm_state, :string
  end
end
