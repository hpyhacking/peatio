class RemoveFundUidExtraFromDeposit < ActiveRecord::Migration
  def change
    remove_column :deposits, :fund_uid
    remove_column :deposits, :fund_extra
  end
end
