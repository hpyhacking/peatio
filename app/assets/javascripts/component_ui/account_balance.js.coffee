@AccountBalanceUI = flight.component ->
  @defaultAttrs
    availableCashSel: '.available-cash .value'
    availableCoinSel: '.available-coin .value'

  @updateAccount = (event, data) ->
    @select('availableCashSel').text(fixAsk data.bid.balance)
    @select('availableCoinSel').text(fixAsk data.ask.balance)

  @after 'initialize', ->
    @on document, 'trade::account', @updateAccount

