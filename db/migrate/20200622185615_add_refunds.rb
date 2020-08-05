class AddRefunds < ActiveRecord::Migration[5.2]
  def change
    create_table :refunds do |t|
      t.references :deposit, null: false
      t.string :state, limit: 30, null: false
      t.string :address, null: false

      t.timestamps
    end

    add_index :refunds, :state
  end
end
