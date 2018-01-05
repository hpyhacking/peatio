class DropTags < ActiveRecord::Migration
  def change
    drop_table :taggings
    drop_table :tags
  end
end
