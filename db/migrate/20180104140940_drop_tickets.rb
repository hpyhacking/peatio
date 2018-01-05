class DropTickets < ActiveRecord::Migration
  def change
    drop_table :tickets
  end
end
