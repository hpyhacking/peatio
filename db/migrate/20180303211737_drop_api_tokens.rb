class DropAPITokens < ActiveRecord::Migration
  def change
    drop_table :api_tokens
  end
end
