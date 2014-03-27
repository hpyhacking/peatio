class RemoveFundSourcesAccountId < ActiveRecord::Migration
  def change
    remove_column :fund_sources, :account_id
  end
end
