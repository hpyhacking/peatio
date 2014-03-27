class ChangeDeposits < ActiveRecord::Migration
  def change
    rename_column :deposits, :address, :fund_source_uid
    rename_column :deposits, :address_label, :fund_source_extra
    rename_column :deposits, :address_type, :channel_id
    rename_column :deposits, :tx_id, :txid
    add_column :deposits, :fee, :decimal, :precision => 32, :scale => 16, :after => :amount
    add_column :deposits, :aasm_state, :string, :after => :state
  end
end
