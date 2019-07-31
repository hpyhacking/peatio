class AddErrorToWithdraw < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :error, :json, after: :note
  end
end
