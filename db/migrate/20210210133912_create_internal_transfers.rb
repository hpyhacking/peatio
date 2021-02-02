class CreateInternalTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_transfers do |t|
      t.string :currency_id, null: false
      t.decimal :amount, precision: 32, scale: 16, null: false
      t.bigint :sender_id, null: false
      t.bigint :receiver_id, null: false
      t.integer :state, default: 1, null: false

      t.timestamps
    end
  end
end
