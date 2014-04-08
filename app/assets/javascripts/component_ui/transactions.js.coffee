window.TransactionsUI = flight.component ->
  @defaultAttrs
    table: 'tbody'
    filter: '.dropdown-menu a'

  @refresh = (data) ->
    $table = @select('table')
    $table.prepend(JST['transaction'](transaction)) for transaction in data.transactions

  @filter = (event) ->
    type = event.target.className
    return @list.filter() if type == ''

    @list.filter (item) ->
      item.values().type == "#{gon.i18n[type]}"

  @initList = ->
    options =
      valueNames: [ 'type', 'timestamp', 'fiat_currency', 'fiat_amount',
      'coin_currency', 'coin_amount', 'coin_price', 'fee' ]
    @list = new List('transactions', options)

  @after 'initialize', ->
    transactions = gon.deposits.concat(gon.withdraws).concat(gon.buys).concat(gon.sells)
    transactions.sort (a, b)->
      a.timestamp - b.timestamp
    @refresh {transactions: transactions}

    @initList()

    @on @select('filter'), 'click', @filter
