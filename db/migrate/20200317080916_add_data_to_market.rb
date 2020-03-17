class AddDataToMarket < ActiveRecord::Migration[5.2]
  def change
    add_column :markets, :data_encrypted, :string, limit: 1024, after: :position
  end
end
