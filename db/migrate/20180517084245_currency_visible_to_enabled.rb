class CurrencyVisibleToEnabled < ActiveRecord::Migration
  def change
    rename_column :currencies, :visible, :enabled
  end
end
