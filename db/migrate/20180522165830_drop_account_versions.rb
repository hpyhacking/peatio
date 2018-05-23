class DropAccountVersions < ActiveRecord::Migration
  def change
    drop_table :account_versions
  end
end
