class DropAccountVersions < ActiveRecord::Migration[4.2]
  def change
    drop_table :account_versions
  end
end
