class AddRefreshedAtToTwoFactors < ActiveRecord::Migration
  def change
    add_column :two_factors, :refreshed_at, :timestamp
  end
end
