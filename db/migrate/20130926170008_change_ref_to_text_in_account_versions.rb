class ChangeRefToTextInAccountVersions < ActiveRecord::Migration
  def change
    change_column :account_versions, :ref, :text
  end
end
