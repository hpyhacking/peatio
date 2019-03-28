class AddNameToCurrency < ActiveRecord::Migration[4.2]
  def change
    add_column :currencies, :name, :string, after: :id, default: nil
  end
end
