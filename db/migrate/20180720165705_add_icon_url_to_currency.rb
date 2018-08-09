class AddIconUrlToCurrency < ActiveRecord::Migration
  def change
    add_column :currencies, :icon_url, :string, after: :precision, default: nil
  end
end
