class CoinWithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Withdraws::Satoshi.where.not(aasm_state: :submitting).order('id desc')
  end

  self.default_column_options = { :order => false }

  column :id
  column_localtime :created_at
  column :fund_uid
  column :fund_extra
  column(:sum) {|withdraw| "#{withdraw.currency_symbol}#{withdraw.sum}"}
  column :actions, html: true, header: '' do |withdraw|
    if withdraw.cancelable?
      content_tag(:span, "#{withdraw.aasm_state_text} / ") +
        link_to(I18n.t('actions.cancel'), url_for([withdraw]), method: :delete)
    else
      withdraw.aasm_state_text
    end
  end
end
