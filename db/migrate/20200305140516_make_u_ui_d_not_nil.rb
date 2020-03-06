class MakeUUIDNotNil < ActiveRecord::Migration[5.2]
  def change
    execute('UPDATE orders SET uuid = (UNHEX(REPLACE(UUID(), "-",""))) WHERE uuid IS NULL')

    change_column :orders, :uuid, :binary, limit: 16, index: {unique: true}, after: :id, null: false
  end
end
