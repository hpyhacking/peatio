window.TradeOrderAskUI = flight.component ->
  @.defaultAttrs
    volumeSel: 'input[id$=volume]'
    appendSel: '.input-append'

  @.after 'initialize', ->
    price = (gon.bids[0] && gon.bids[0][0]) || null
    @.$node.trigger 'price', price

    @.on 'order', (event, data) ->
      zero = BigNumber(0)
      @.trigger document, 'trade::order', { ask: zero.minus(data.volume), bid: data.sum, order: 'ask' }

    @.on 'order_empty', ->
      @.trigger document, 'trade::order', {order: 'ask'}

    @.select('volumeSel').wrap("<div class=input-append></div>")
    $("<span class=add-on><i class='fa fa-bolt'></i></span>").appendTo(@.select('appendSel')).click =>
      @.select('volumeSel').val(gon.accounts.ask.balance).fixAsk().trigger 'change'
