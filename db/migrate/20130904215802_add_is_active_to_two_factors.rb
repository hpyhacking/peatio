class AddIsActiveToTwoFactors < ActiveRecord::Migration
  def change
    add_column :two_factors, :is_active, :boolean
  end
end
