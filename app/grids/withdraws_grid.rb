class WithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do |m|
    Withdraw.not_completed.
      order('created_at asc, state desc')
  end

  self.default_column_options = { :order => false } 

  column :sn
  column :name do |o|
    o.member.name
  end
  column :currency_text
  column :channel do |w|
    w.channel.key
  end
  column :fund_extra
  column :amount
  column :fee
  column :created_at
  column :state_text
  column :position_in_queue do |o|
    o.position_in_queue if o.position_in_queue > 0
  end
  column :actions, html: true, header: '' do |o|
    link_to I18n.t('actions.view'), edit_admin_withdraw_path(o)
  end
end
