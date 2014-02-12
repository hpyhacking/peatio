class DropResetPins < ActiveRecord::Migration
  def up
    drop_table :reset_pins
  end

  def down
    create_table :reset_pins do |t|
      t.string :email
      t.string :token
      t.datetime :expire_at
      t.integer :identity_id
      t.boolean :is_used

      t.timestamps
    end
  end
end
