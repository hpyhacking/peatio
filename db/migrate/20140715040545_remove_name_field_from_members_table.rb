class RemoveNameFieldFromMembersTable < ActiveRecord::Migration
  def change
    remove_column :members, :name
  end
end
