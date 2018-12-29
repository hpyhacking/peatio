class AddNameToCurrency < ActiveRecord::Migration
  def change
    add_column :currencies, :name, :string, after: :id, default: nil
  end
end
