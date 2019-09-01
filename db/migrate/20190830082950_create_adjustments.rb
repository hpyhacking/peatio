class CreateAdjustments < ActiveRecord::Migration[5.2]
  def change
    create_table :adjustments do |t|

      t.string :reason, null: false
      t.text :description, null: false
      t.bigint :creator_id, null: false
      t.bigint :validator_id, null: true
      t.decimal :amount, precision: 32, scale: 16, null: false
      t.integer :asset_account_code, limit: 2, unsigned: true, null: false
      t.string :receiving_account_number, limit: 64, null: false
      t.string :currency_id, null: false
      t.integer :category, limit: 1, null: false
      t.integer :state, limit: 1, null: false
      t.timestamps null: false

    end

    add_index :adjustments, :currency_id
    add_index :adjustments, %i[currency_id state]
  end
end
