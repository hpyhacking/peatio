class AddCurrencyStates < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :deposit_enabled, :boolean, default: true, null: false, after: :enabled
    add_column :currencies, :withdrawal_enabled, :boolean, default: true, null: false, after: :deposit_enabled
    rename_column :currencies, :enabled, :visible
    if index_exists?(:currencies, :visible, name: 'index_currencies_on_enabled_and_code')
      remove_index :currencies, name: :index_currencies_on_enabled_and_code
    end
  end
end
