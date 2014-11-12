@OrderBookUI = flight.component ->
  @attributes
    bookLimit: 30
    askBookSel: 'table.asks'
    bidBookSel: 'table.bids'
    seperatorSelector: 'table.seperator'
    fade_toggle_depth: '#fade_toggle_depth'

  @update = (event, data) ->
    @updateOrders(@select('bidBookSel'), _.first(data.bids, @.attr.bookLimit), 'bid')
    @updateOrders(@select('askBookSel'), _.first(data.asks, @.attr.bookLimit), 'ask')

  @updateOrders = (table, orders, bid_or_ask) ->
    template = JST["templates/order_book_#{bid_or_ask}"]

    book = @select("#{bid_or_ask}BookSel")
    rows = book.find('tr')

    i = j = 0
    while(true)
      row = rows[i]
      order = orders[j]
      $row = $(row)

      if row && order
        p1 = new BigNumber($row.data('price'))
        v1 = new BigNumber($row.data('volume'))
        p2 = new BigNumber(order[0])
        v2 = new BigNumber(order[1])
        if (bid_or_ask == 'ask' && p2 < p1) || (bid_or_ask == 'bid' && p2 > p1)
          $row.before template(price: order[0], volume: order[1], index: j)
          j += 1
        else if p1 == p2
          if v1 != v2
            $row.data('volume', order[1])
            $row.find('td.volume').text(formatter.amount(order[1], order[0]))
          else
            # do nothing
          $row.data('order', j)
          i += 1
          j += 1
        else
          $row.remove()
          i += 1
      else if row
        $row.remove()
        i += 1
      else if order
        book.append template(price: order[0], volume: order[1], index: j)
        j += 1
      else
        break

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
    @on document, 'market::order_book::update', @update

    @on @select('fade_toggle_depth'), 'click', =>
      @trigger 'market::depth::fade_toggle'

    $('.asks').on 'click', 'tr', (e) =>
      i = $(e.target).closest('tr').data('order')
      @placeOrder $('#bid_entry'), _.extend(@computeDeep(e, gon.asks), type: 'ask')
      @placeOrder $('#ask_entry'), {price: BigNumber(gon.asks[i][0]), volume: BigNumber(gon.asks[i][1])}

    $('.bids').on 'click', 'tr', (e) =>
      i = $(e.target).closest('tr').data('order')
      @placeOrder $('#ask_entry'), _.extend(@computeDeep(e, gon.bids), type: 'bid')
      @placeOrder $('#bid_entry'), {price: BigNumber(gon.bids[i][0]), volume: BigNumber(gon.bids[i][1])}
