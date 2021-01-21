class AddUsernameToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :username, :string, null: true
    add_index :members, :username, unique: true, where: 'username IS NOT NULL'
  end
end
