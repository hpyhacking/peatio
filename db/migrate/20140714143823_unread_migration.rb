class UnreadMigration < ActiveRecord::Migration
  def self.up
    create_table :read_marks, :force => true do |t|
      t.integer  :readable_id
      t.integer  :member_id,       :null => false
      t.string   :readable_type, :null => false, :limit => 20
      t.datetime :timestamp
    end

    add_index :read_marks, [:member_id]
    add_index :read_marks, [:readable_type, :readable_id]

  end

  def self.down
    drop_table :read_marks
  end
end
