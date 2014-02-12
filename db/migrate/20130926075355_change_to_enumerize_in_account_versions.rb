class ChangeToEnumerizeInAccountVersions < ActiveRecord::Migration
  def up
    change_column :account_versions, :reason, :integer

    if index_exists?(:account_versions, [:item_type, :item_id])
      remove_index :account_versions, [:item_type, :item_id]
    end

    unless index_exists?(:account_versions, [:item_type, :item_id, :reason])
      add_index :account_versions, [:item_type, :item_id, :reason]
    end
  end

  def down
    change_column :account_versions, :reason, :string

    if index_exists?(:account_versions, [:item_type, :item_id, :reason])
      remove_index :account_versions, [:item_type, :item_id, :reason]
    end

    unless index_exists?(:account_versions, [:item_type, :item_id])
      add_index :account_versions, [:item_type, :item_id]
    end
  end
end
