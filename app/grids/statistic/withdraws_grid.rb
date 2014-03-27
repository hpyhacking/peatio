module Statistic
  class WithdrawsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Withdraw.includes(:account).order(id: :desc)
    end

    filter(:channel, :enum, :select => WithdrawChannel.all, :default => 100, :include_blank => false)
    filter(:state, :enum, :select => Withdraw.state.value_options, :default => 500)
    filter(:created_at, :datetime, :range => true, :default => proc { [1.day.ago, Time.now]})

    column(:member) do |model|
      format(model) do 
        link_to model.account.member.name, member_path(model.member_id)
      end
    end

    column :currency do
      self.account.currency_text
    end

    column(:channel)
    column(:amount)
    column(:address) do
      self.address.mask
    end
    column_i18n(:created_at)
    column(:state_text)
  end
end
