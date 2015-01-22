class RenameWithdrawAddressesToFundSources < ActiveRecord::Migration
  def change
    rename_table :withdraw_addresses, :fund_sources
  end
end
