class PrivateDepositsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Deposit.order('id DESC')
  end

  column(:txid)
  column_i18n(:created_at)
  column(:amount)
  column(:channel_key_text)
  column(:fund_extra_text)
  column(:fund_uid)
  column(:aasm_state_text)
  column(:memo)
end
