class RemoveSolvency < ActiveRecord::Migration[4.2]
  def change
    drop_table :partial_trees
    drop_table :proofs
  end
end
