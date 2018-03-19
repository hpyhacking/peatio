class DepositChannel extends PeatioModel.Model
  @configure 'DepositChannel', 'currency', 'min_confirm', 'max_confirm'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        DepositChannel.create(record)

  account: ->
    Account.findBy('currency', @currency)

window.DepositChannel = DepositChannel

