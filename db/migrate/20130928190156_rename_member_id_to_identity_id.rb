class RenameMemberIdToIdentityId < ActiveRecord::Migration
  def up
    rename_column :reset_pins, :member_id, :identity_id
  end

  def down
    rename_column :reset_pins, :identity_id, :member_id
  end
end
