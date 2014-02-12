window.TradeAccountUI = flight.component ->
  @.defaultAttrs
    lockedFundsSelector: '.locked-funds'
    availableFundsSelector: '.available-funds'
    orderFundsSelector: '.order-funds'

  @.updateFunds = (event, data) ->
    locked = @.select('lockedFundsSelector')
    available = @.select('availableFundsSelector')

    locked.find('span.ask').text(fixAsk data.ask.locked)
    locked.find('span.bid').text(fixBid data.bid.locked)

    available.find('span.ask').text(fixAsk data.ask.balance)
    available.find('span.bid').text(fixBid data.bid.balance)

  @.updateOrder = (event, data) ->
    return unless data.order == @.attr.order

    if data.ask and data.bid
      order = @.select('orderFundsSelector')
      order.find('span.ask').text(fixAsk data.ask)
      order.find('span.bid').text(fixBid data.bid)
    else
      order = @.select('orderFundsSelector')
      order.find('span.ask').text('-')
      order.find('span.bid').text('-')
    
  @.after 'initialize', ->
    @.attr.order = @.$node.data('order')
    @.on document, 'trade::account', @.updateFunds
    @.on document, 'trade::order', @.updateOrder
    @.updateFunds '', gon.accounts
    @.updateOrder '', {ask: BigNumber(0), bid: BigNumber(0)}
