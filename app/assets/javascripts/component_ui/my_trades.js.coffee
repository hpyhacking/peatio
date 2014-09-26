@MyTradesUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @getTemplate = (order) -> $(JST["order_done"](order))

  @orderHandler = (event, order) ->
    @addOrUpdateItem order

  @.after 'initialize', ->
    @on document, 'trade::done::populate', @populate
    @on document, 'trade::done', @orderHandler


