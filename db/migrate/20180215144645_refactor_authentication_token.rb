class RefactorAuthenticationToken < ActiveRecord::Migration
  def change
    change_column :authentications, :secret, :text
    rename_column :authentications, :secret, :token
  end
end
