class Currency extends PeatioModel.Model
  @configure 'Currency', 'key', 'code', 'coin', 'key', 'blockchain'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Currency.create(record)

window.Currency = Currency



