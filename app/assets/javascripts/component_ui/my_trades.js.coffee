@MyTradesUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin]

  @attributes
    switchLinkName: '.switch-link-name'
    switchLink: 'a.switch'
    table: 'table'

  @getTemplate = (order) -> $(JST["order_done"](order))

  @orderHandler = (event, order) ->
    @addOrUpdateItem order

  @switch = (event) ->
    link = $(event.target)
    @select('switchLinkName').text link.text()
    if link.hasClass('buy')
      @select('table').addClass('hidden-sell')
      @select('table').removeClass('hidden-buy')
    else if link.hasClass('sell')
      @select('table').addClass('hidden-buy')
      @select('table').removeClass('hidden-sell')
    else
      @select('table').removeClass('hidden-buy')
      @select('table').removeClass('hidden-sell')

  @.after 'initialize', ->
    @on document, 'trade::done::populate', @populate
    @on document, 'trade::done', @orderHandler
    @on @select('switchLink'), 'click', @switch


