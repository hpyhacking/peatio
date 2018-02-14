class DropAssets < ActiveRecord::Migration
  def change
    drop_table :assets
  end
end
