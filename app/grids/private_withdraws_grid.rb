class PrivateWithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Withdraw.where.not(aasm_state: :submitting).order('id desc')
  end

  self.default_column_options = { :order => false }

  column :created_at
  column(:sum) {|withdraw| "#{withdraw.currency_symbol}#{withdraw.sum}"}
  column(:fund_uid) {|withdraw| "#{withdraw.fund_uid} (#{withdraw.fund_extra})" }
  column :position_in_queue do |o|
    o.position_in_queue if o.position_in_queue > 0
  end
  column :actions, html: true, header: '' do |withdraw|
    if withdraw.cancelable?
      link_to I18n.t('actions.cancel'), withdraw_path(withdraw), method: :delete
    else
      withdraw.state_text
    end
  end
end
