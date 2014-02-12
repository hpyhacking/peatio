class ChangeToEnumerizeInPaymentTransactions < ActiveRecord::Migration
  def up
    change_column :payment_transactions, :state, :integer
  end

  def down
    change_column :payment_transactions, :state, :string
  end
end
