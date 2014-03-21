I18n.defaultLocale = 'en'
I18n.locale = gon.local

$ ->
  $.fn.extend
    fixAsk: ->
      if $(@).text().length
        $(@).text(window.fixAsk $(@).text())
      else if $(@).val().length
        val = window.fixAsk $(@).val()
        $(@).val(val)
      $(@)

    fixBid: ->
      if $(@).text().length
        $(@).text(window.fixBid $(@).text())
      else if $(@).val().length
        val = window.fixBid $(@).val()
        $(@).val(val)
      $(@)

  window.round = (str, fixed) ->
    zero = Array(fixed - 1).join("0")
    numeral(BigNumber(str).round(fixed, 1).toString()).format("0.00[#{zero}]")

  window.fix = (type, str) ->
    if type is 'ask'
      window.round(str, gon.market.ask.fixed)
    else if type is 'bid'
      window.round(str, gon.market.bid.fixed)

  window.fixAsk = (str) ->
    window.fix('ask', str)

  window.fixBid = (str) ->
    window.fix('bid', str)

  $('[data-clipboard-text], [data-clipboard-target]').each ->
    zero = new ZeroClipboard($(@))

    zero.on 'complete', ->
      $(zero.htmlBridge)
        .attr('title', gon.clipboard.done)
        .tooltip('fixTitle')
        .tooltip('show')
    zero.on 'mouseout', ->
      $(zero.htmlBridge)
        .attr('title', gon.clipboard.click)
        .tooltip('fixTitle')

    placement = $(@).data('placement') || 'bottom'
    $(zero.htmlBridge).tooltip({title: gon.clipboard.click, placement: placement})

  if gon.env is 'development'
    Pusher.log = (message) ->
      window.console && console.log(message)

  pusher = new Pusher(gon.pusher_key, {encrypted: true});

  GlobalData.attachTo(document, {pusher: pusher})
  AccountData.attachTo(document, {pusher: pusher}) if gon.accounts
  OrderData.attachTo(document, {pusher: pusher}) if gon.current_user

  MarketTickerUI.attachTo('.ticker')
  MarketOrdersUI.attachTo('.orders')
  MarketTradesUI.attachTo('.trades')

  TradeAccountUI.attachTo('.account-wrapper')

  TradeOrderUI.attachTo('.order-wrapper')
  TradeOrderBidUI.attachTo('#bid_panel .order-wrapper')
  TradeOrderAskUI.attachTo('#ask_panel .order-wrapper')

  for type in ['ask', 'bid']
    for state in ['wait', 'cancel', 'done']
      return unless gon.orders
      orders = (o for o in gon.orders[state])
      data = orders: orders.reverse(), state: state, type: type, market: gon.market
      selector = "##{type}_panel .history-wrapper .orders-#{state}"
      TradeHistoryUI.attachTo(selector, data)
      TradeHistoryWaitUI.attachTo(selector) if state is 'wait'
      TradeHistoryCancelUI.attachTo(selector) if state is 'cancel'
      TradeHistoryDoneUI.attachTo(selector) if state is 'done'

  $(".ask-panel, .bid-panel").click ->
    $(document).trigger('history::resize', gon.history_height)
