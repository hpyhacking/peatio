class AddCountryCodeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :country_code, :integer
  end
end
