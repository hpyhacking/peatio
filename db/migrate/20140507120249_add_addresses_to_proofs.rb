class AddAddressesToProofs < ActiveRecord::Migration
  def change
    add_column :proofs, :addresses, :text
  end
end
