class AddPaymentIdToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :payment_id, :string
  end
end
