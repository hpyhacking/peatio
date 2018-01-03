class DropDoorkeeperTables < ActiveRecord::Migration
  def change
    drop_table :oauth_applications
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    remove_column :api_tokens, :oauth_access_token_id
  end
end
