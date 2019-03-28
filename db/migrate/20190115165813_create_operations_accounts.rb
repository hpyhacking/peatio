class CreateOperationsAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :operations_accounts do |t|
      t.integer :code,          null: false, limit: 3,  index: { unique: true }
      t.string :type,           null: false, limit: 10, index: true
      t.string :kind,           null: false, limit: 30
      t.string :currency_type,  null: false, limit: 10, index: true
      t.string :description,                 limit: 100
      t.string :scope,          null: false, limit: 10, index: true

      t.timestamps null: false
    end

    add_index :operations_accounts, %i[type kind currency_type], unique: true
  end
end
