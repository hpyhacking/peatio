class DeleteTableAccountVersions < ActiveRecord::Migration
  def up
    drop_table :account_versions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
