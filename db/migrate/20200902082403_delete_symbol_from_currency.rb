class DeleteSymbolFromCurrency < ActiveRecord::Migration[5.2]
  def change
    remove_column :currencies, :symbol, :string
  end
end
