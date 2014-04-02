class CreatePartialTrees < ActiveRecord::Migration
  def change
    create_table :partial_trees do |t|
      t.integer :proof_id, null: false
      t.integer :account_id, null: false
      t.text :json, null: false

      t.timestamps
    end
  end
end
