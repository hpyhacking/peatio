class CreateTokens < ActiveRecord::Migration
  def up
    create_table :tokens do |t|
      t.string :token
      t.datetime :expire_at
      t.integer :identity_id
      t.boolean :is_used
      t.string :type

      t.timestamps
    end

    add_index :tokens, [:type, :token, :expire_at, :is_used]
  end

  def down
    drop_table :tokens
  end
end
