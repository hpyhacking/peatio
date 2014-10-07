@OrderBookUI = flight.component ->
  @attributes
    bookCounter: 10
    askBookSel: 'table.asks'
    bidBookSel: 'table.bids'
    seperatorSelector: 'table.seperator'

  @refreshSeperator = (event, data) ->
    attrs = {trade: data.trades[0], hint: gon.i18n.latest_trade}
    seperator = @select('seperatorSelector')
    seperator.fadeOut ->
      seperator.html(JST['order_book_seperator'](attrs)).fadeIn()

  @refreshOrders = (event, data) ->
    @buildOrders(@select('bidBookSel'), _.first(data.bids, 200), 'bid')
    @buildOrders(@select('askBookSel'), _.first(data.asks, 200), 'ask')

  @buildOrders = (table, orders, bid_or_ask) ->
    book = @select("#{bid_or_ask}BookSel")
    book.empty()
    html = ''
    for i in [0...orders.length]
      data = price: orders[i][0], volume: orders[i][1], index: i
      html += JST["order_book_#{bid_or_ask}"](data)
    book.append(html)

  @computeDeep = (event, orders) ->
    index      = Number $(event.currentTarget).data('order')
    orders     = _.take(orders, index + 1)

    volume_fun = (memo, num) -> memo.plus(BigNumber(num[1]))
    volume     = _.reduce(orders, volume_fun, BigNumber(0))
    price      = BigNumber(_.last(orders)[0])
    origVolume = _.last(orders)[1]

    {price: price, volume: volume, origVolume: origVolume}

  @placeOrder = (target, data) ->
      @trigger target, 'place_order::input::price', data
      @trigger target, 'place_order::input::volume', data

  @after 'initialize', ->
    @on document, 'market::order_book', @refreshOrders
    @on document, 'market::trades', @refreshSeperator

    $('.asks').on 'click', 'tr', (e) =>
      @placeOrder $('#bid_entry'), _.extend(@computeDeep(e, gon.asks), type: 'ask')

    $('.bids').on 'click', 'tr', (e) =>
      @placeOrder $('#ask_entry'), _.extend(@computeDeep(e, gon.bids), type: 'bid')
