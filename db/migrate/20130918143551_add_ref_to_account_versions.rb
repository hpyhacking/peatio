class AddRefToAccountVersions < ActiveRecord::Migration
  def change
    add_column :account_versions, :ref, :string
  end
end
