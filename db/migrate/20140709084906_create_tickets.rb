class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :content
      t.string :aasm_state
      t.integer :author_id

      t.timestamps
    end
  end
end
