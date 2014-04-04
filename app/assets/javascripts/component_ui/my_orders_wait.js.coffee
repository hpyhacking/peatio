@MyOrdersWaitUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @getTemplate = (order) -> $(JST["order_wait"](order))

  @orderHandler = (event, order) ->
    switch order.state
      when 'wait'
        @addOrUpdateItem order
      when 'cancel'
        @removeItem order.id
      when 'done'
        @removeItem order.id

  @.after 'initialize', ->
    @populate gon.orders.wait
    @on document, 'order::wait order::cancel order::done', @orderHandler

