class PrivateWithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Withdraw.order('id desc')
  end

  self.default_column_options = { :order => false } 

  column :created_at
  column :sum
  column :address
  column :state_text
  column :position_in_queue do |o|
    o.position_in_queue if o.position_in_queue > 0
  end
  column :actions, html: true, header: '' do |o|
    link_to I18n.t('actions.view'), edit_withdraw_path(o)
  end
end
