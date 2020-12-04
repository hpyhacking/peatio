class AddIndexOnMembersUID < ActiveRecord::Migration[5.2]
  def change
    add_index :members, :uid, unique: true unless index_exists?(:members, :uid)
  end
end
