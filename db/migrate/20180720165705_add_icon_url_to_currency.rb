class AddIconUrlToCurrency < ActiveRecord::Migration[4.2]
  def change
    add_column :currencies, :icon_url, :string, after: :precision, default: nil
  end
end
