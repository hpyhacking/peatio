class CoinDepositsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Deposits::Satoshi.order('id DESC')
  end

  column(:txid)
  column_localtime :created_at
  column(:amount)
  column(:aasm_state_text)
  column(:memo)
end
