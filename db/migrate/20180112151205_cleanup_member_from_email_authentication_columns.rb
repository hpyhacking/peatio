class CleanupMemberFromEmailAuthenticationColumns < ActiveRecord::Migration
  def change
    remove_column :members, :identity_id
    remove_column :members, :display_name
    remove_column :members, :activated
    remove_column :members, :state
    remove_column :members, :country_code
  end
end
