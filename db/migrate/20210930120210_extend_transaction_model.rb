class ExtendTransactionModel < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :blockchain_key, :string, after: :currency_id unless column_exists?(:transactions, :blockchain_key)
    add_column :transactions, :kind, :string, after: :currency_id unless column_exists?(:transactions, :kind)
    add_column :transactions, :fee, :decimal, precision: 32, scale: 16, after: :amount unless column_exists?(:transactions, :fee)
    add_column :transactions, :fee_currency_id, :string, after: :currency_id, null: false unless column_exists?(:transactions, :fee_currency_id)
  end
end
