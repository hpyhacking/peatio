class ChangeDataEngine < ActiveRecord::Migration[5.2]
  def change
    change_column :engines, :data_encrypted, :string, limit: 1024
  end
end
