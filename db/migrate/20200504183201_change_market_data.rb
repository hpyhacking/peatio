class ChangeMarketData < ActiveRecord::Migration[5.2]
  def change
    rename_column :markets, :data_encrypted, :data
    change_column :markets, :data, :json
  end
end
