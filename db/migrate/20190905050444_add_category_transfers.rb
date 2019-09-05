class AddCategoryTransfers < ActiveRecord::Migration[5.2]
  def up
    change_column :transfers, :key, :string, limit: 30, null: false
    remove_column :transfers, :kind if column_exists?(:transfers, :kind)
    add_column :transfers, :category, :integer, limit: 1, null: false, after: :key
    rename_column :transfers, :desc, :description if column_exists?(:transfers, :desc)
  end

  def down
    change_column :transfers, :key, :integer, null: false
    remove_column :transfers, :category if column_exists?(:transfers, :category)
    add_column :transfers, :kind, :string, limit: 30, null: false, after: :key
    rename_column :transfers, :description, :desc if column_exists?(:transfers, :description)
  end
end
