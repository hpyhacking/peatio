class RemoveSolvency < ActiveRecord::Migration
  def change
    drop_table :partial_trees
    drop_table :proofs
  end
end
