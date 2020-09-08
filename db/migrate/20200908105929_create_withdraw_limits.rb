class CreateWithdrawLimits < ActiveRecord::Migration[5.2]
  def change
    create_table :withdraw_limits do |t|

      t.string :group, limit: 32, default: 'any', null: false, index: true
      t.string :kyc_level, limit: 32, default: 'any', null: false, index: true

      t.decimal :limit_24_hour, precision: 32, scale: 16, default: 0, null: false
      t.decimal :limit_1_month, precision: 32, scale: 16, default: 0, null: false

      t.timestamps

    end
    add_index :withdraw_limits, %i[group kyc_level], unique: true
  end
end
