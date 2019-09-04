class CreateBeneficiaries < ActiveRecord::Migration[5.2]
  def change
    create_table :beneficiaries do |t|
      t.references  :member,      null: false
      t.string      :currency_id, null: false, limit: 10,            index: true
      t.string      :name,        null: false, limit: 64
      t.string      :description, default: ''
      t.json        :data
      t.integer     :pin,         null: false, limit: 3,             unsigned: true
      t.integer     :state,       null: false, limit: 1, default: 0, unsigned: true
      t.timestamps
    end
  end
end
