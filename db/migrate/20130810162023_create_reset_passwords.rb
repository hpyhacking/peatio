class CreateResetPasswords < ActiveRecord::Migration
  def change
    create_table :reset_passwords do |t|
      t.string :email
      t.string :token
      t.datetime :expire_at
      t.integer :identity_id
      t.boolean :is_used

      t.timestamps
    end

    create_table :reset_pins do |t|
      t.string :email
      t.string :token
      t.datetime :expire_at
      t.integer :account_id
      t.boolean :is_used

      t.timestamps
    end
  end
end
