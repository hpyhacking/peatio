class FundSourcesIsLockedDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :fund_sources, :is_locked, false
  end
end
