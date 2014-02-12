class AddDeletedAtToWithdrawAddresses < ActiveRecord::Migration
  def change
    add_column :withdraw_addresses, :deleted_at, :datetime
  end
end
