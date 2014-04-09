class BankWithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Withdraws::Bank.where.not(aasm_state: :submitting).order('id desc')
  end

  self.default_column_options = { :order => false }

  column :id
  column_localtime :created_at
  column :fund_extra_text
  column :fund_uid
  column(:sum) {|withdraw| "#{withdraw.currency_symbol}#{withdraw.sum}"}
  column :position_in_queue do |o|
    o.position_in_queue if o.position_in_queue > 0
  end
  column :actions, html: true, header: '' do |withdraw|
    if withdraw.cancelable?
      content_tag(:span, "#{withdraw.aasm_state_text} / ") +
        link_to(I18n.t('actions.cancel'), withdraw_path(withdraw), method: :delete)
    else
      content_tag(:span, withdraw.aasm_state_text)
    end
  end
end
