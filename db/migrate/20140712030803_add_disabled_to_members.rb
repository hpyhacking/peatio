class AddDisabledToMembers < ActiveRecord::Migration
  def change
    add_column :members, :disabled, :boolean, default: false
  end
end
