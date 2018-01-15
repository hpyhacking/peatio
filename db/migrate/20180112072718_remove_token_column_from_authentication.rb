class RemoveTokenColumnFromAuthentication < ActiveRecord::Migration
  def change
    remove_column :authentications, :token
  end
end
