class ChangeEmailToLoginForIdentities < ActiveRecord::Migration
  def change
    rename_column :identities, :email, :login

    add_column :identities, :login_type, :string
  end
end
