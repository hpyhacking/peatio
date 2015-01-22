class AddDisplaynameToMembers < ActiveRecord::Migration
  def change
    add_column :members, :display_name, :string, after: :name
  end
end
