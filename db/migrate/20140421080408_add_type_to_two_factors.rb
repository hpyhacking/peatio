class AddTypeToTwoFactors < ActiveRecord::Migration
  def change
    add_column :two_factors, :type, :string
  end
end
