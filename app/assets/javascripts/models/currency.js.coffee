class Currency extends PeatioModel.Model
  @configure 'Currency', 'key', 'code', 'coin', 'blockchain'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record.attributes)
        currency.set('key', currency.key)
        currency.set('code', currency.code)
        currency.set('coin', currency.coin)
        currency.set('blockchain', currency.blockchain)

window.Currency = Currency
