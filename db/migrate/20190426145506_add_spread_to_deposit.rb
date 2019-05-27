class AddSpreadToDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :deposits, :spread, :string,
               limit: 1000, after: :tid
  end

  def down
    remove_column :deposits, :spread
  end
end
