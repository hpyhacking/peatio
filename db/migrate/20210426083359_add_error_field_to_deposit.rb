class AddErrorFieldToDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :deposits, :error, :json, after: :spread
  end
end
