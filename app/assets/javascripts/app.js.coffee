@App =
  showInfo:   (msg) -> $(document).trigger 'flash-info',   msg: msg
  showNotice: (msg) -> $(document).trigger 'flash-notice', msg: msg
  showAlert:  (msg) -> $(document).trigger 'flash-alert',  msg: msg

$ ->
  gutter = 2
  gutter_2x = 2 * 2
  gutter_3x = 2 * 3
  gutter_4x = 2 * 4
  gutter_5x = 2 * 5
  gutter_6x = 2 * 6
  gutter_7x = 2 * 7
  gutter_8x = 2 * 8
  gutter_9x = 2 * 9

  $(window).resize ->
    navbar_h = $('.navbar').height() + 1
    window_w = $(window).width()
    window_h = $(window).height()
    sidebar_w = $('.sidebar').width()
    trades_w = $('#trades').width()
    trades_h = $('#trades').height()
    entry_h = $('#ask_entry').height()
    ticker_h = $('#ticker').height()
    my_orders_w = $('#my_orders').width()
    order_book_w = $('#order_book').width()
    $('.content').width(window_w- sidebar_w)
    $('.content').height(window_h - navbar_h)
    $('#ticker, #kline_chart').width(window_w - sidebar_w - order_book_w - gutter_5x)
    $('#chat').width(window_w - sidebar_w - order_book_w - trades_w - my_orders_w - gutter_9x)
    $('#kline_chart').height(window_h - navbar_h - ticker_h - trades_h - gutter_7x)
    $('.market-chart').height($('#kline_chart').height() - 20)
    $('#order_book').height(window_h - navbar_h - entry_h - gutter_5x)
    $('#order_book .panel-body-content').height(window_h - navbar_h - entry_h - gutter_5x - 73)
    $('#trades, #my_orders, #my_done_orders').width((window_w - sidebar_w - order_book_w - gutter_7x) / 2)

  $(window).resize()

  BigNumber.config(ERRORS: false)

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

  $('.qrcode-container').each (index, el) ->
    $el = $(el)
    new QRCode el,
      text:   $el.data('text')
      width:  $el.data('width')
      height: $el.data('height')

  AccountBalanceUI.attachTo('.account-balance')
  PlaceOrderUI.attachTo('#bid_entry')
  PlaceOrderUI.attachTo('#ask_entry')
  MyOrdersUI.attachTo('#my_orders')
  MyDoneOrdersUI.attachTo('#my_done_orders')

  MarketChartUI.attachTo('.market-chart')
  MarketTickerUI.attachTo('.ticker')
  MarketTradesUI.attachTo('#trades')
  OrderBookUI.attachTo('#order_book')

  TransactionsUI.attachTo('#transactions')
  VerifyMobileNumberUI.attachTo('#new_token_sms_token')
  FlashMessageUI.attachTo('.flash-message')
  TwoFactorAuth.attachTo('.two-factor-auth-container')

  # if gon.env is 'development'
  #   Pusher.log = (message) -> window.console && console.log(message)
  pusher = new Pusher gon.pusher_key, gon.pusher_options
  pusher.connection.bind 'state_change', (state) ->
    if state.current is 'unavailable'
      $('#markets-show .pusher-unavailable').removeClass('hide')

  GlobalData.attachTo(document, {pusher: pusher})
  MemberData.attachTo(document, {pusher: pusher}) if gon.accounts

  $('.tab-content').on 'mousewheel DOMMouseScroll', (e) ->
    $(@).scrollTop(@scrollTop + e.deltaY)
    e.preventDefault()

  notifier = window.notifier = new Notifier()

