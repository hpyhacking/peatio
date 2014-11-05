class AddOauthAccessTokenIdToAPITokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :oauth_access_token_id, :integer
  end
end
