@MyTradesUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin, NotificationMixin]

  @attributes
    switchLinkName: '.switch-link-name'
    switchLink: 'a.switch'
    table: 'table'

  @getTemplate = (order) -> $(JST["order_done"](order))

  @tradeHandler = (event, trade) ->
    @addOrUpdateItem trade
    message = gon.i18n.notification.new_trade
      .replace(/%{kind}/g, gon.i18n[trade.kind])
      .replace(/%{id}/g, trade.id)
      .replace(/%{price}/g, trade.price)
      .replace(/%{volume}/g, trade.volume)
      .replace(/%{base_unit}/g, gon.market.base_unit.toUpperCase())
      .replace(/%{quote_unit}/g, gon.market.quote_unit.toUpperCase())
    @notify message

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
    @on document, 'trade::done', @tradeHandler
    @on @select('switchLink'), 'click', @switch


