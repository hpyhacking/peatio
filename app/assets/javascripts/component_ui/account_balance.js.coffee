@AccountBalanceUI = flight.component ->
  @defaultAttrs
    availableCashSel: '.available-cash .value'
    availableCoinSel: '.available-coin .value'
    lockedCashSel: '.locked-cash .value'
    lockedCoinSel: '.locked-coin .value'

  @updateAccount = (event, data) ->
    @select('availableCashSel').text(fixAsk data.bid.balance)
    @select('availableCoinSel').text(fixAsk data.ask.balance)
    @select('lockedCashSel').text(fixBid data.bid.locked)
    @select('lockedCoinSel').text(fixBid data.bid.locked)

  @after 'initialize', ->
    @on document, 'trade::account', @updateAccount
    @trigger document, 'trade::account', gon.accounts

