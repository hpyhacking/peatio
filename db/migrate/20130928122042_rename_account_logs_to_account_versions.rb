class RenameAccountLogsToAccountVersions < ActiveRecord::Migration
  def change
    rename_table :account_logs, :account_versions
  end
end
