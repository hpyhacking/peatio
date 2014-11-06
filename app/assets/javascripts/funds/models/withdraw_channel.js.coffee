class WithdrawChannel extends PeatioModel.Model
  @configure 'WithdrawChannel', 'key', 'currency', 'resource_name'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        WithdrawChannel.create(record.attributes)

  account: ->
    Account.findBy('currency', @currency)

window.WithdrawChannel = WithdrawChannel
