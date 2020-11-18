class AddWithdrawMetadata < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :metadata, :json, after: :note
  end
end
