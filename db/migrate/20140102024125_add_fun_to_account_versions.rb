class AddFunToAccountVersions < ActiveRecord::Migration
  def change
    add_column :account_versions, :fun, :integer
  end
end
