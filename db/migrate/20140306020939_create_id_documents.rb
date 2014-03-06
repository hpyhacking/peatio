class CreateIdDocuments < ActiveRecord::Migration
  def change
    create_table :id_documents do |t|
      t.integer :category
      t.string :name
      t.string :sn
      t.integer :member_id

      t.timestamps
    end
  end
end
