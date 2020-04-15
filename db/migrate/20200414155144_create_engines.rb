class CreateEngines < ActiveRecord::Migration[5.2]
  def change
    create_table :engines do |t|
      t.string :name, null: false
      t.string :driver, null: false
      t.string :uid
      t.string :url
      t.string :key_encrypted
      t.string :secret_encrypted
      t.json :data_encrypted
      t.integer :state, default: 1, null: false
    end

    add_reference :markets, :engine, index: true, null: false, after: :quote_unit
    add_column :orders, :remote_id, :string, after: :uuid
  end
end
