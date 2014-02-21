window.TradeOrderAskUI = flight.component ->
  @.defaultAttrs
    volumeSel: 'input[id$=volume]'
    appendSel: '.input-group'

  @.after 'initialize', ->
    price = (gon.bids[0] && gon.bids[0][0]) || null
    @.$node.trigger 'price', price

    @.on 'order', (event, data) ->
      zero = BigNumber(0)
      @.trigger document, 'trade::order', { ask: zero.minus(data.volume), bid: data.sum, order: 'ask' }

    @.on 'order_empty', ->
      @.trigger document, 'trade::order', {order: 'ask'}

    @.select('volumeSel').wrap("<div class=input-group></div>")
    $("<span class=input-group-btn><button class='btn btn-default btn-warning' type='button'><i class='fa fa-bolt'></i></button></span>").appendTo(@.select('appendSel')).click =>
      @.select('volumeSel').val(gon.accounts.ask.balance).fixAsk().trigger 'change'
