class RemovePinDigestFromIdentities < ActiveRecord::Migration
  def up
    remove_column :identities, :pin_digest
  end

  def down
    add_column :identities, :pin_digest, :string
  end
end
