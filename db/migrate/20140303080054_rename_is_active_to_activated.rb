class RenameIsActiveToActivated < ActiveRecord::Migration
  def change
    change_table :two_factors do |t|
      t.rename :is_active, :activated
    end
  end
end
