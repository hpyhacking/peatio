class CurrencyVisibleToEnabled < ActiveRecord::Migration[4.2]
  def change
    rename_column :currencies, :visible, :enabled
  end
end
