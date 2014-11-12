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

  @appendRow = (book, template, data) ->
    data.classes = 'new'
    book.append template(data)
    book.find("tr[data-order=#{data.index}]").fadeIn('slow')

  @insertRow = (book, row, template, data) ->
    data.classes = 'new'
    row.before template(data)
    book.find("tr[data-order=#{data.index}]").fadeIn('slow')

  @remove = (rows) ->
    rows.fadeOut 'slow', ->
      rows.remove()

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
        if (bid_or_ask == 'ask' && p2.lessThan(p1)) || (bid_or_ask == 'bid' && p2.greaterThan(p1))
          console.log "insert"
          @insertRow(book, $row, template, price: order[0], volume: order[1], index: j)
          j += 1
        else if p1.equals(p2)
          if v1.equals(v2)
            # do nothing
          else
            $row.data('volume', order[1])
            $row.find('td.volume').html(formatter.amount(order[1], order[0]))
          $row.data('order', j)
          i += 1
          j += 1
        else
          $row.addClass 'obsolete'
          i += 1
      else if row
        $row.addClass 'obsolete'
        i += 1
      else if order
        @appendRow(book, template, price: order[0], volume: order[1], index: j)
        j += 1
      else
        break

    setTimeout =>
      book.find('tr.new').removeClass('new')
      @remove book.find('tr.obsolete')
    , 900

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
