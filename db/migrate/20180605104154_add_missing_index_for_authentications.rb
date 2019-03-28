class AddMissingIndexForAuthentications < ActiveRecord::Migration[4.2]
  def change
    add_index :authentications, [:provider, :member_id, :uid], unique: true
  end
end
