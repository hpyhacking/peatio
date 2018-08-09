class Currency extends PeatioModel.Model
  @configure 'Currency', 'id', 'coin', 'explorer_transaction'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record.attributes)

window.Currency = Currency
