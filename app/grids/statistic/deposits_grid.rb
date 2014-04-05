module Statistic
  class DepositsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Deposit.includes(:account).order('created_at DESC')
    end

    filter(:currency, :enum, :select => Deposit.currency.value_options, :default => 1)
    filter(:created_at, :datetime, :range => true, :default => proc { [1.day.ago, Time.now]})

    column :member do |model|
      format(model) do 
        link_to model.member, member_path(model.member)
      end
    end
    column :currency do
      self.account.currency_text
    end
    column(:amount)
    column(:txid) do |deposit|
      deposit.txid
    end
    column_localtime :created_at
    column(:aasm_state_text)
  end
end
