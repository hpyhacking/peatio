class AddAasmStateToIdDocument < ActiveRecord::Migration
  def change
    add_column :id_documents, :aasm_state, :string
  end
end
