class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :sn
      t.string :name
      t.string :email
      t.string :pin_digest
      t.integer :identity_id
      t.timestamps
    end

    create_table :accounts do |t|
      t.integer :member_id
      t.string  :currency
      t.decimal :balance, :precision => 32, :scale => 16
      t.decimal :locked, :precision => 32, :scale => 16
      t.timestamps
    end
  end
end
