class RemoveNotNullFromCurrencyOptions < ActiveRecord::Migration[5.0]
  def change
    change_column :currencies, :options, :string, limit: 1000, default: '{}', null: true
  end
end
