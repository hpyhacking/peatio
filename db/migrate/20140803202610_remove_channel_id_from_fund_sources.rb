class RemoveChannelIdFromFundSources < ActiveRecord::Migration
  def change
    remove_column :fund_sources, :channel_id
  end
end
