class AddCurrencyToAccountVersions < ActiveRecord::Migration
  def up
    add_column :account_versions, :currency, :integer
    remove_column :account_versions, :detail
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
