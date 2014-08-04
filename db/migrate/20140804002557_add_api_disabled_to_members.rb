class AddAPIDisabledToMembers < ActiveRecord::Migration
  def change
    add_column :members, :api_disabled, :boolean, default: false
  end
end
