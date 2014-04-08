class RemoveWithdrawsStateAndChannelId < ActiveRecord::Migration
  def change
    remove_column :withdraws, :channel_id
    remove_column :withdraws, :state
  end
end
