class CreateAPITokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.integer :member_id, null: false
      t.string :access_key, null: false, limit: 50
      t.string :secret_key, null: false, limit: 50

      t.timestamps
    end

    add_index :api_tokens, :access_key, unique: true
    add_index :api_tokens, :secret_key, unique: true
  end
end
