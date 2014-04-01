class AccountVersionsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do |m|
    AccountVersion.order("id DESC")
  end

  filter(:currency, :enum, :select => Deposit.currency.value_options)
  filter(:reason, :enum, :select => AccountVersion.reason.value_options)

  column_localtime :created_at
  column :currency_text, :order => false

  column :modifiable_type, :order => false do |m|
    if m.modifiable_type
      "#{I18n.t("activerecord.models.#{m.modifiable_type.underscore}", default: m.modifiable_type)} ##{m.modifiable_id}"
    else
      'N/A'
    end
  end

  column :reason_text, :order => false
  column :out, :order => false
  column :in, :order => false
  column :amount, :order => false
  column :fee, :order => false do |m|
    if m.fee and not m.fee.zero?
      m.fee
    end
  end
end
