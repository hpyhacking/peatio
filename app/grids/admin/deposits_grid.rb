module Admin
  class DepositsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do |m|
      Deposit.order('id DESC')
    end

    column :sn
    column_i18n :created_at
    column :full_name
    column :channel_key_text
    column :fund_extra_text do |o|
      o.try(:fund_extra_text) || o.try(:fund_extra)
    end
    column :fund_uid
    column :currency_text
    column :aasm_state_text
  end
end
