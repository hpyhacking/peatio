class RenameFundSourcesCategoryToChannelId < ActiveRecord::Migration
  def change
    rename_column :fund_sources, :category, :channel_id
  end
end
