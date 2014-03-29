@MyOrdersWaitUI = flight.component ->
  flight.compose.mixin @, [MyOrdersMixin]

  @getTemplate = (order) -> $(JST["order_wait"](order))

  @orderHandler = (event, order) ->
    switch order.state
      when 'wait'
        @addOrUpdateOrder order
      when 'cancel'
        @removeOrder order
      when 'done'
        @removeOrder order

  @.after 'initialize', ->
    @populate gon.orders.wait
    @on document, 'order::wait order::cancel order::done', @orderHandler

