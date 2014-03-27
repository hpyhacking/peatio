@MyOrdersWaitUI = flight.component ->
  @defaultAttrs
    table: 'table > tbody'
    empty: '.empty-row'

  @checkEmpty = (event, data) ->
    if @select('table').find('tr.order').length is 0
      @select('empty').show()
    else
      @select('empty').hide()

  @populate = (data) ->
    if _.isEmpty(data)
      @select('empty').show()
    else
      @select('empty').hide()

      for order in data
        $(JST["orders_wait"](order)).appendTo(@select('table')).show('slow')

  @addOrder = (order) ->
    template = $(JST["orders_wait"](order))
    existsOrder = @select('table').find("tr[data-id=#{order.id}]")

    if existsOrder.length
      existsOrder.html template.html()
    else
      template.appendTo(@select('table')).show('slow')

    @checkEmpty()

  @removeOrder = (order) ->
    $tr = @.select('table').find("tr[data-id=#{order.id}]")
    $tr.hide =>
      $tr.remove()
      @checkEmpty()

  @updateOrder = (event, order) ->
    switch order.state
      when 'wait'
        @addOrder order
      when 'cancel'
        @removeOrder order
      when 'done'
        @removeOrder order

  @.after 'initialize', ->
    @populate gon.orders.wait
    @on document, 'order::wait order::cancel order::done', @updateOrder

