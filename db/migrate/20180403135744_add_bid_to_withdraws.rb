class AddBidToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :bid, :string, limit: 64
  end
end
