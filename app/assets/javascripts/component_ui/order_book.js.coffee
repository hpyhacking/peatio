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

  @insertRow = (book, row, template, data) ->
    data.classes = 'new'
    row.before template(data)

  @updateRow = (row, order, index, v1, v2) ->
    row.data('order', index)
    return if v1.equals(v2)

    if v2.greaterThan(v1)
      row.addClass('text-up')
    else
      row.addClass('text-down')

    row.data('volume', order[1])
    row.find('td.volume').html(formatter.mask_fixed_volume(order[1]))
    row.find('td.amount').html(formatter.amount(order[1], order[0]))

  @mergeUpdate = (bid_or_ask, book, orders, template) ->
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
          @insertRow(book, $row, template,
            price: order[0], volume: order[1], index: j)
          j += 1
        else if p1.equals(p2)
          @updateRow($row, order, j, v1, v2)
          i += 1
          j += 1
        else
          $row.addClass 'obsolete'
          i += 1
      else if row
        $row.addClass 'obsolete'
        i += 1
      else if order
        @appendRow(book, template,
          price: order[0], volume: order[1], index: j)
        j += 1
      else
        break

  @clearMarkers = (book) ->
    book.find('tr.new').removeClass('new')
    book.find('tr.text-up').removeClass('text-up')
    book.find('tr.text-down').removeClass('text-down')

    obsolete = book.find('tr.obsolete')
    obsolete_divs = book.find('tr.obsolete div')
    obsolete_divs.slideUp 'slow', ->
      obsolete.remove()

  @updateOrders = (table, orders, bid_or_ask) ->
    book = @select("#{bid_or_ask}BookSel")

    @mergeUpdate bid_or_ask, book, orders, JST["templates/order_book_#{bid_or_ask}"]

    book.find("tr.new div").slideDown('slow')
    setTimeout =>
      @clearMarkers(@select("#{bid_or_ask}BookSel"))
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
