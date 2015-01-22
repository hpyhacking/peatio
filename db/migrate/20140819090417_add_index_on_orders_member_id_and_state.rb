class AddIndexOnOrdersMemberIdAndState < ActiveRecord::Migration
  def change
    add_index :orders, [:member_id, :state]
  end
end
