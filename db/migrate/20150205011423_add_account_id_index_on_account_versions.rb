class AddAccountIdIndexOnAccountVersions < ActiveRecord::Migration
  def change
    add_index :account_versions, :account_id
  end
end
