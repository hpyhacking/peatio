window.OrderBookUI = flight.component ->
  @defaultAttrs
    size: 10,
    asksSelector: '.table.asks',
    bidsSelector: '.table.bids',

  @refreshOrders = (event, data) ->
    @buildOrders(@select('asksSelector'), data.asks, gon.i18n.ask)
    @buildOrders(@select('bidsSelector'), data.bids, gon.i18n.bid)

  @buildOrders = (table, orders, prefix) ->
    $(table).find('tr').each (i, e) ->
      i = parseInt($(e).data('order'))
      sn = "#{prefix} <g>##{i}</g>"
      if orders[i]
        data = {price: orders[i][0], amount: orders[i][1], sn: sn}
        $(e).empty().append(JST["market_order"](data))
      else
        $(e).empty().append(JST["market_order_empty"]({sn: sn}))

  @computeDeep = (e, orders) ->
    index = parseInt $(e.currentTarget).data('order')
    orders = _.take(orders, index + 1)

    volume_fun = (memo, num) -> memo.plus(BigNumber(num[1]))
    sum_fun = (memo, num) -> memo.plus(BigNumber(num[0]).times(BigNumber(num[1])))

    volume = _.reduce(orders, volume_fun, BigNumber(0))
    sum = _.reduce(orders, sum_fun, BigNumber(0))
    price = _.last(orders)[0]
    avg_price = sum.dividedBy(volume)
    # order-price, order-deep-volume, order-avg-price
    {price: price, volume: volume, avg_price: avg_price}

  @after 'initialize', ->
    @on document, 'market::order_book', @refreshOrders

    _(10).times (n) =>
      @select('asksSelector').prepend("<tr data-order='#{n}'></tr>")
      @select('bidsSelector').append("<tr data-order='#{n}'></tr>")

    @refreshOrders '', {asks: gon.asks, bids: gon.bids}

    @$node.on 'click', '.asks tr', (e) =>
      $('.bid-panel').click()
      @trigger document, 'order::plan', @computeDeep(e, gon.asks)

    @$node.on 'click', '.bids tr', (e) =>
      $('.ask-panel').click()
      @trigger document, 'order::plan', @computeDeep(e, gon.bids)

