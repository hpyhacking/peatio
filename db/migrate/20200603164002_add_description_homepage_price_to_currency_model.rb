class AddDescriptionHomepagePriceToCurrencyModel < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :description, :text, after: :name
    add_column :currencies, :homepage, :string, after: :description
    add_column :currencies, :price, :decimal, precision: 32, scale: 16, after: :icon_url
  end
end
