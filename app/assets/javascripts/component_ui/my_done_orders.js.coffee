@MyDoneOrdersUI = flight.component ->
  flight.compose.mixin @, [ItemListMixin, NotificationMixin]

  @attributes
    table: 'table'
    switchLink: 'a.switch-link'
    switchLinkName: '.switch-link-name'

  @getTemplate = (order_or_trade) -> $(JST["templates/order_done"](order_or_trade))

  @trade = (event, trade) ->
    return if trade.market != gon.market.id

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
    # first of all, use user's done order fill the table.
    # add new trade in table when trigger trade event.
    @on document, 'trade', @trade
    @on document, 'order::done::populate', @populate
    @on @select('switchLink'), 'click', @switch
