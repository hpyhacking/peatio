class RemoveTableMembersTrades < ActiveRecord::Migration
  def change
    drop_table :members_trades
  end
end
