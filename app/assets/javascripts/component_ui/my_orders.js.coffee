@MyOrdersUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

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
