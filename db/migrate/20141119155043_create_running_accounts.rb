class CreateRunningAccounts < ActiveRecord::Migration
  def change
    create_table :running_accounts do |t|
      t.integer :category
      t.decimal :income, precision: 32, scale: 16, null: false, default: 0
      t.decimal :expenses, precision: 32, scale: 16, null: false, default: 0
      t.integer :currency
      t.references :member, index: true
      t.references :source, polymorphic: true, index: true
      t.string :note

      t.timestamps
    end
  end
end
