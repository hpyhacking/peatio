@MyOrdersDoneUI = flight.component ->
  flight.compose.mixin @, [MyOrdersMixin]

  @getTemplate = (order) -> $(JST["order_done"](order))

  @orderHandler = (event, order) ->
    @addOrUpdateOrder order

  @.after 'initialize', ->
    @populate gon.orders.done
    @on document, 'order::done', @orderHandler


