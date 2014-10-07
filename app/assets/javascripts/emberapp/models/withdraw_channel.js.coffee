class WithdrawChannel extends PeatioModel.Model
  @configure 'WithdrawChannel', 'key', 'currency'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        WithdrawChannel.create(record.attributes)

  account: ->
    Account.findBy('currency', @currency)

window.WithdrawChannel = WithdrawChannel
