class AddConfirmationsToWithdraw < ActiveRecord::Migration
  def change
    add_column :withdraws, :confirmations, :integer, limit: 4, default: 0, null: false, after: :rid
  end
end
