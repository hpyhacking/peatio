@MyOrdersDoneUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @getTemplate = (order) -> $(JST["order_done"](order))

  @orderHandler = (event, order) ->
    @addOrUpdateItem order

  @.after 'initialize', ->
    @populate gon.orders.done
    @on document, 'order::done', @orderHandler


