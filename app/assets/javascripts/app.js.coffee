@App =
  showInfo:   (msg) -> $(document).trigger 'flash-info',   msg: msg
  showNotice: (msg) -> $(document).trigger 'flash-notice', msg: msg
  showAlert:  (msg) -> $(document).trigger 'flash-alert',  msg: msg

$ ->
  if $('#assets-index').length
    $.scrollIt
      topOffset: -180
      activeClass: 'active'

    $('a.go-verify').on 'click', (e) ->
      e.preventDefault()

      root         = $('.tab-pane.active .root.json pre').text()
      partial_tree = $('.tab-pane.active .partial-tree.json pre').text()

      if partial_tree
        uri = 'http://syskall.com/proof-of-liabilities/#verify?partial_tree=' + partial_tree + '&expected_root=' + root
        window.open(encodeURI(uri), '_blank')

  $('[data-clipboard-text], [data-clipboard-target]').each ->
    zero = new ZeroClipboard $(@), forceHandCursor: true

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

  # if gon.env is 'development'
  #   Pusher.log = (message) ->
  #     window.console && console.log(message)

  pusher = new Pusher(gon.pusher_key, {encrypted: true})
  pusher.connection.bind 'state_change', (state) ->
    if state.current is 'unavailable'
      $(document).trigger 'pusher:unavailable'

  GlobalData.attachTo(document, {pusher: pusher})
  AccountData.attachTo(document, {pusher: pusher}) if gon.accounts
  OrderData.attachTo(document, {pusher: pusher}) if gon.current_user

  AccountBalanceUI.attachTo('.account-balance')
  PlaceOrderUI.attachTo('.order-enter #bid_panel')
  PlaceOrderUI.attachTo('.order-enter #ask_panel')
  MyOrdersWaitUI.attachTo('.my-orders #orders_wait')
  MyOrdersDoneUI.attachTo('.my-orders #orders_done')
  PushButton.attachTo('.order-enter')
  PushButton.attachTo('.my-orders')

  MarketTickerUI.attachTo('.ticker')
  MarketOrdersUI.attachTo('.orders')
  MarketTradesUI.attachTo('.trades')
  MarketChartUI.attachTo('.price-chart')

  TransactionsUI.attachTo('#transactions')
  FlashMessageUI.attachTo('.flash-message')

