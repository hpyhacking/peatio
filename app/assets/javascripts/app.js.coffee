@App =
  showInfo:   (msg) -> $(document).trigger 'flash-info',   msg: msg
  showNotice: (msg) -> $(document).trigger 'flash-notice', msg: msg
  showAlert:  (msg) -> $(document).trigger 'flash-alert',  msg: msg

$ ->
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
  PlaceOrderUI.attachTo('.order-place #bid_panel')
  PlaceOrderUI.attachTo('.order-place #ask_panel')
  MyOrdersUI.attachTo('.my-orders')
  MyTradesUI.attachTo('.my-trades')

  MarketTickerUI.attachTo('.ticker')
  MarketTradesUI.attachTo('.trades')
  MarketChartUI.attachTo('.market-chart')
  OrderBookUI.attachTo('.order-book')

  TransactionsUI.attachTo('#transactions')
  VerifyMobileNumberUI.attachTo('#new_sms_token')
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


  if "Notification" of window
    if Notification.permission == 'denied'
      $('input[name="notification-checkbox"]').remove()
    else
      notification_check = (event, state) ->
        if state
          fun = (permission) ->
            if permission == 'granted'
              Cookies.set('notification', true, 30)
              new Notification(gon.i18n.notification.title, {body: gon.i18n.notification.enabled, tag: 0})
            else if permission == 'denied'
              Cookies.set('notification', false, 30)
          Notification.requestPermission(fun) if Notification.permission == 'default'
          Cookies.set('notification', true, 30) if Notification.permission == 'granted'
        else
          Cookies.set('notification', false, 30)

      val = (Cookies('notification') == 'true') ? 'true' : 'false'
      $('input[name="notification-checkbox"]').bootstrapSwitch({state: val, onSwitchChange: notification_check})
  else
    $('input[name="notification-checkbox"]').bootstrapSwitch(disabled: true)
