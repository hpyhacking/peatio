class AddAlipayToMembers < ActiveRecord::Migration
  def up
    add_column :identities, :pin_digest, :string
    remove_column :members, :pin_digest
  end

  def down
    remove_column :identities, :pin_digest
    add_column :members, :pin_digest, :string
  end
end
