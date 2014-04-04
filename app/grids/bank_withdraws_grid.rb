class BankWithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Withdraws::Bank.where.not(aasm_state: :submitting).order('id desc')
  end

  self.default_column_options = { :order => false }

  column :sn
  column :created_at
  column(:sum, header: '') {|withdraw| "#{withdraw.currency_symbol}#{withdraw.sum}"}
  column(:fund_uid) do |withdraw|
    if withdraw.respond_to?(:fund_extra_text) 
      "#{withdraw.fund_extra_text} #{withdraw.fund_uid}"
    else
      "#{withdraw.fund_uid} #{withdraw.fund_extra}"
    end
  end
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
