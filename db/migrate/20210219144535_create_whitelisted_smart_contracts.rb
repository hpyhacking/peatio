class CreateWhitelistedSmartContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :whitelisted_smart_contracts do |t|
      t.string  :description
      t.string  :address,        null: false
      t.string  :state,          null: false, limit: 30
      t.string  :blockchain_key, null: false, limit: 32
      t.timestamps
    end

    add_index :whitelisted_smart_contracts, %w[address blockchain_key], unique: true
  end
end
