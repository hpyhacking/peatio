class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :email
      t.string :password_digest
      t.boolean :is_active
      t.integer :retry_count
      t.boolean :is_locked
      t.datetime :locked_at
      t.datetime :last_verify_at
      t.timestamps
    end
  end
end
