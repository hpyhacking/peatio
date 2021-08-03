class AddDefaultNetworkToCurrenciesTable < ActiveRecord::Migration[5.2]
  def up
    unless column_exists? :currencies, :default_network_id
      add_column :currencies, :default_network_id , :bigint, null: true, after: :type
    end
  end

  def down
    if column_exists? :currencies, :default_network_id
      remove_column :currencies, :default_network_id , :bigint
    end
  end
end
