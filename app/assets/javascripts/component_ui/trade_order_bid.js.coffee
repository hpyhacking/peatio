window.TradeOrderBidUI = flight.component ->
  @.defaultAttrs
    sumSel: 'input[id$=sum]'
    appendSel: '.input-append'

  @.after 'initialize', ->
    price = (gon.asks[0] && gon.asks[0][0]) || null
    @.$node.trigger 'price', price

    @.on 'order', (event, data) ->
      zero = BigNumber(0)
      @.trigger document, 'trade::order', { ask: data.volume, bid: zero.minus(data.sum), order: 'bid'}

    @.on 'order_empty', ->
      @.trigger document, 'trade::order', {order: 'bid'}

    @.select('sumSel').wrap("<div class=input-append></div>")
    @.select('appendSel').append
    $("<span class=add-on><i class='fa fa-bolt'></i></span>").appendTo(@.select('appendSel')).click =>
      @.select('sumSel').val(gon.accounts.bid.balance).fixBid().trigger 'change'
