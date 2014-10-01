@OrderBookUI = flight.component ->
  @attributes
    bookCounter: 10
    asksBookSel: 'table.asks'
    bidsBookSel: 'table.bids'
    seperatorSelector: 'table.seperator'

  @refreshSeperator = (event, data) ->
    attrs = {trade: data.trades[0], hint: gon.i18n.latest_trade}
    seperator = @select('seperatorSelector')
    seperator.fadeOut ->
      seperator.html(JST['order_book_seperator'](attrs)).fadeIn()

  @refreshOrders = (event, data) ->
    @buildOrders(@select('bidsBookSel'), data.bids)
    @buildOrders(@select('asksBookSel'), data.asks)

  @buildOrders = (table, orders) ->
    for i in [0...@attr.bookCounter]
      tableItem = table.find("tr[data-order='#{i}']")
      if order = orders[i]
        data = price: order[0], amount: order[1]
        tableItem.html(JST["order_book"](data))
      else
        tableItem.html(JST['order_book_empty'])

  @computeDeep = (event, orders) ->
    index = Number $(event.currentTarget).data('order')
    orders = _.take(orders, index + 1)

    volume_fun = (memo, num) -> memo.plus(BigNumber(num[1]))
    volume = _.reduce(orders, volume_fun, BigNumber(0))
    price = _.last(orders)[0]

    {price: price, volume: volume}

  @after 'initialize', ->
    for n in [0...@attr.bookCounter]
      @select('asksBookSel').prepend("<tr data-order='#{n}'></tr>")
      @select('bidsBookSel').append("<tr data-order='#{n}'></tr>")

    @on document, 'market::order_book', @refreshOrders
    @on document, 'market::trades', @refreshSeperator

    @on '.asks tr', 'click', (e) =>
      @trigger document, 'order::plan', @computeDeep(e, gon.asks)

    @on '.bids tr', 'click', (e) =>
      @trigger document, 'order::plan', @computeDeep(e, gon.bids)

