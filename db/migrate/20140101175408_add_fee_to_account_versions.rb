class AddFeeToAccountVersions < ActiveRecord::Migration
  def change
    add_column :account_versions, :fee, :decimal, precision: 32, scale: 16, after: :locked
  end
end
