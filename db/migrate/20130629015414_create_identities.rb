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

    create_table :two_factors do |t|
      t.integer :identity_id
      t.string :otp_secret
      t.datetime :last_verify_at
    end
  end
end
