class WithdrawsGrid
  include Datagrid
  include Datagrid::Naming
  include Datagrid::ColumnI18n

  scope do |m|
    Withdraw.order('created_at asc, state desc')
  end

  filter(:state_text, :enum, select: Withdraw.state.options) do |state, scope|
    scope.with_state(state) if state
  end

  filter(:channel, :enum, select: WithdrawChannel.all.map{|w| [w.key, w.id]}) do |channel, scope|
    scope.with_channel(channel) if channel
  end

  filter(:created_at, :date, :range => true, :default => proc { [1.month.ago.to_date, Date.tomorrow]}) do |arr, scope|
    scope.where(created_at: Range.new(arr.first, arr.last)) unless arr.any?(&:blank?)
  end

  column :sn
  column :created_at
  column :name do |o|
    o.member.name
  end
  column :channel do |w|
    w.channel.key
  end
  column :fund_extra, order: false
  column :sum
  column :state_text
  column :position_in_queue do |o|
    o.position_in_queue if o.position_in_queue > 0
  end
  column :actions, html: true, header: '' do |o|
    link_to I18n.t('actions.view'), edit_admin_withdraw_path(o)
  end
end
