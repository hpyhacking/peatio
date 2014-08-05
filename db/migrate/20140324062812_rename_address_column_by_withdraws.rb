class RenameAddressColumnByWithdraws < ActiveRecord::Migration
  def change
    add_column :fund_sources, :member_id, :integer, :after => :id
    add_column :fund_sources, :currency, :integer, :after => :member_id
    rename_column :fund_sources, :label, :extra
    rename_column :fund_sources, :address, :uid

    rename_column :withdraws, :address, :fund_source_uid
    rename_column :withdraws, :address_label, :fund_source_extra
    rename_column :withdraws, :address_type, :withdraw_channel_id
  end
end
