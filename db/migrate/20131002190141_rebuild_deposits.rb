class RebuildDeposits < ActiveRecord::Migration
  def change
    change_table :deposits do |t|
      t.integer :member_id, :after => :account_id
      t.integer :currency, :after => :member_id
      t.datetime :done_at
      t.rename :payment_way, :category
      t.rename :payment_id, :tx_id
    end
  end
end
