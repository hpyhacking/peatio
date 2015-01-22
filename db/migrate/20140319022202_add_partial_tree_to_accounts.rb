class AddPartialTreeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :partial_tree, :text
  end
end
