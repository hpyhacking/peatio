class ChangeDefaultOfWithdraoFee < ActiveRecord::Migration
  def change
    change_column :withdraws, :sum, :decimal, precision: 32, scale: 16, default: 0, null: false
  end
end
