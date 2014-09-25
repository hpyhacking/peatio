class DepositChannel extends PeatioModel.Model
  @configure 'DepositChannel', 'key', 'currency', 'min_confirm', 'max_confirm', 'bank_accounts'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        DepositChannel.create(record.attributes)

  account: ->
    Account.findBy('currency', @currency)

window.DepositChannel = DepositChannel

