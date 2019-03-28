class CreateRevenues < ActiveRecord::Migration[4.2]
  def change
    create_table :revenues do |t|
      t.integer     :code,        null: false
      t.string      :currency_id, null: false, index: true, foreign_key: true
      t.references  :reference,         null: false, index: true, polymorphic: true
      t.decimal     :debit,       null: false, default: 0, precision: 32, scale: 16
      t.decimal     :credit,      null: false, default: 0, precision: 32, scale: 16

      t.timestamps null: false
    end
  end
end
