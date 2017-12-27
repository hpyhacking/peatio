class DropTwoFactors < ActiveRecord::Migration
  def change
    if table_exists?(:two_factors)
      drop_table :two_factors
    end
  end
end
