class CreateTriggers < ActiveRecord::Migration[5.2]
  def change
    create_table :triggers do |t|
      t.references :order,      null: false, index: true
      t.integer    :order_type, null: false, index: true, limit: 1, unsigned: true
      t.binary     :value,      null: false, limit: 128
      t.integer    :state,      null: false, default: 0,  index: true, limit: 1, unsigned: true
      t.timestamps
    end
  end
end
