class AddDefaultNetworkToCurrenciesTable < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :default_network_id , :bigint, null: true, after: :type
  end
end
