class AddMissingIndexForAuthentications < ActiveRecord::Migration
  def change
    add_index :authentications, [:provider, :member_id, :uid], unique: true
  end
end
