class BankDepositsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Deposit.order('id DESC')
  end

  column(:sn)
  column_i18n(:created_at)
  column(:channel_key_text)
  column(:fund_extra_text)
  column(:fund_uid)
  column(:amount)
  column(:aasm_state_text, html: true) do |o|
    view_link = if o.may_submit?
                  link_to(o.aasm_state_text, url_for([:edit, o]))
                else
                  link_to(o.aasm_state_text, url_for(o))
                end
    if o.aasm_state.submitting?
      view_link + content_tag(:span, ' / ') +
      link_to(t('actions.cancel'), deposit_path(o), method: :delete)
    else
      view_link
    end
  end
end
