class AddTypeToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :type, :string
  end
end
