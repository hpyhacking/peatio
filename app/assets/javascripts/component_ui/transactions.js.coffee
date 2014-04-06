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
