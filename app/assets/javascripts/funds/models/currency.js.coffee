class Currency extends PeatioModel.Model
  @configure 'Currency', 'id', 'coin', 'transaction_url_template'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record.attributes)

window.Currency = Currency
