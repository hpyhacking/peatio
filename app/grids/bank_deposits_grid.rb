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
    if o.aasm_state.submitting?
      link_to o.aasm_state_text, url_for(o)
    else
      o.aasm_state_text
    end
  end
end
