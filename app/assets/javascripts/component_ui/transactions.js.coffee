window.TransactionsUI = flight.component ->
  @defaultAttrs
    table: 'tbody'

  @refresh = (data) ->
    $table = @select('table')
    $table.prepend(JST['transaction'](transaction)) for transaction in data.transactions

  @after 'initialize', ->
    transactions = gon.deposits.concat(gon.withdraws).concat(gon.buys).concat(gon.sells)
    transactions.sort (a, b)->
      a.timestamp - b.timestamp
    @refresh {transactions: transactions}

    options =
      valueNames: [ 'type', 'timestamp', 'fiat_currency', 'fiat_amount',
      'coin_currency', 'coin_amount', 'coin_price', 'fee' ]
    window.list = new List('transactions', options)
