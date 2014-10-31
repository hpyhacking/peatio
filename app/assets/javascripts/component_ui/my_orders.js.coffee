@MyOrdersUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @attributes
    switchMyDoneOrderLink: 'a.switch_my_done_orders'

  @getTemplate = (order) -> $(JST["templates/order_active"](order))

  @orderHandler = (event, order) ->
    switch order.state
      when 'wait'
        @addOrUpdateItem order
      when 'cancel'
        @removeItem order.id
      when 'done'
        @removeItem order.id

  @.after 'initialize', ->
    @on document, 'order::wait::populate', @populate
    @on document, 'order::wait order::cancel order::done', @orderHandler

    @on @select('switchMyDoneOrderLink'), 'click', ->
      $('#my_orders').hide()
      $('#my_done_orders').show()
