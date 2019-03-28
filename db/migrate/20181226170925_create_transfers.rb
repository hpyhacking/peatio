class CreateTransfers < ActiveRecord::Migration[4.2]
  def change
    create_table :transfers do |t|
      t.integer :key,                           null: false, index: { unique: true }
      t.string  :kind, limit: 30,               null: false, index: true
      t.string  :desc, limit: 255, default: ''

      t.timestamps null: false
    end
  end
end
