class AddFeeToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :member_id, :integer, :after => :account_id
    add_column :withdraws, :currency, :integer, :after => :member_id
    add_column :withdraws, :fee, :decimal, :precision => 32, :scale => 16, :after => :amount
  end
end
