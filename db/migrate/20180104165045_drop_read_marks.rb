class DropReadMarks < ActiveRecord::Migration
  def change
    drop_table :read_marks
  end
end
