class AddActivatedToMembers < ActiveRecord::Migration
  def change
    add_column :members, :activated, :boolean
  end
end
