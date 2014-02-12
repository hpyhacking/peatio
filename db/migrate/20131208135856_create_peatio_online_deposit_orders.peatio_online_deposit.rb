# This migration comes from peatio_online_deposit (originally 20131208094749)
class CreatePeatioOnlineDepositOrders < ActiveRecord::Migration
  def change
    create_table :peatio_online_deposit_orders do |t|
      t.string :sn
      t.decimal :amount, precision: 32, scale: 16
      t.decimal :fee, precision: 32, scale: 16
      t.integer :member_id
      t.string :channel
      t.integer :state
      t.string :type
      t.text :details
      t.timestamps
      t.datetime :done_at
    end
  end
end
