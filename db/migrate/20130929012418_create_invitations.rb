class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.boolean :is_used
      t.string :token
      t.string :email

      t.timestamps
    end
  end
end
