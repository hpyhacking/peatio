class RemoveUidLimitForMember < ActiveRecord::Migration[5.2]
  def change
    change_column :members, :uid, :string, limit: 32, null: false
  end
end
