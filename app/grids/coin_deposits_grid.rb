class CoinDepositsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do
    Deposit.order('id DESC')
  end

  column(:txid)
  column_i18n(:created_at)
  column(:aasm_state)
end
