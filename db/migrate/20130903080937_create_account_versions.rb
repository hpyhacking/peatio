class CreateAccountVersions < ActiveRecord::Migration
  def self.up
    create_table :account_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.string   :reason
      t.integer  :ref_id
    end
    add_index :account_versions, [:item_type, :item_id]
  end

  def self.down
    remove_index :account_versions, [:item_type, :item_id]
    drop_table :account_versions
  end
end
