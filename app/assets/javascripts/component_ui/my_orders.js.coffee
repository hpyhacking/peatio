@MyOrdersUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @getTemplate = (order) -> $(JST["templates/order_active"](order))

  @orderHandler = (event, order) ->
    return unless order.market == gon.market.id

    switch order.state
      when 'wait'
        @addOrUpdateItem order
      when 'cancel'
        @removeItem order.id
      when 'done'
        @removeItem order.id

  @cancelOrder = (event) ->
    tr = $(event.target).parents('tr')
    if confirm(formatter.t('place_order')['confirm_cancel'])
      $.ajax
        url: formatter.market_url gon.market.id, tr.data('id')
        method: 'delete'

  @.after 'initialize', ->
    @on document, 'order::wait::populate', @populate
    @on document, 'order::wait order::cancel order::done', @orderHandler
    @on @select('tbody'), 'click', @cancelOrder
