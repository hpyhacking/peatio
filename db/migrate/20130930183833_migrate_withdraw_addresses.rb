class MigrateWithdrawAddresses < ActiveRecord::Migration
  def up
    change_table :members do |t|
      t.remove :alipay
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
