class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :secret
      t.integer :member_id

      t.timestamps
    end

    add_index :authentications, :member_id
    add_index :authentications, [:provider, :uid]
  end
end
