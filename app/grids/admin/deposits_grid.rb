module Admin
  class DepositsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do |m|
      Deposit.order('id DESC')
    end

    filter(:assm_state_text, :enum, select: Deposit::STATE) do |state, scope|
      scope.with_aasm_state(state) if state
    end

    #filter(:channel, :enum, select: DepositChannel.all.map{|w| [w.key, w.id]}) do |channel, scope|
      #scope.with_channel(channel) if channel
    #end

    filter(:created_at, :date, :range => true, :default => proc { [1.month.ago.to_date, Date.tomorrow]}) do |arr, scope|
      scope.where(created_at: Range.new(arr.first, arr.last)) unless arr.any?(&:blank?)
    end

    column :sn
    column_localtime :created_at
    column :full_name
    column :currency_text
    column :channel_key_text
    column :txid, html: true do |o|
      if o.currency_obj.coin?
        content_tag(:a, href: o.currency_obj.blockchain_url(o.txid), target: '_blank') do
          content_tag(:code, o.txid.truncate(10, omission: '..'))
        end
      elsif o.txid
        content_tag(:code, o.txid.truncate(10, omission: '..'))
      end
    end
    column :fund_extra_text do |o|
      o.try(:fund_extra_text) || o.try(:fund_extra)
    end
    column :fund_uid
    column :aasm_state_text, html: true do |o|
      content_tag(:span, "#{o.admin_aasm_state_text} / ") +
        link_to(t('actions.view'), edit_admin_deposit_path(o))
    end
  end
end
