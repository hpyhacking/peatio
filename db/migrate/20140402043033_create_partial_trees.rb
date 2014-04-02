class CreatePartialTrees < ActiveRecord::Migration
  def up
    create_table :partial_trees do |t|
      t.integer :proof_id, null: false
      t.integer :account_id, null: false
      t.text :json, null: false

      t.timestamps
    end

    remove_column :accounts, :partial_tree

    Proof.delete_all
  end
end
