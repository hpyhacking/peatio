class AddGasSpeedToBlockchains < ActiveRecord::Migration[5.2]
  def change
    add_column :blockchains, :collection_gas_speed, :string, null: true, after: :height
    add_column :blockchains, :withdrawal_gas_speed, :string, null: true, after: :collection_gas_speed
  end
end
