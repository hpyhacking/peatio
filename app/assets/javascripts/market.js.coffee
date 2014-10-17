#= require es5-shim.min
#= require es5-sham.min
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require bootstrap-switch.min
#
#= require scrollIt
#= require moment
#= require bignumber
#= require underscore
#= require handlebars.runtime
#= require introjs
#= require ZeroClipboard
#= require flight.min
#= require pusher.min
#= require highstock
#= require highstock_config
#= require list
#= require helper
#= require jquery.mousewheel
#= require jquery-timing.min
#= require qrcode
#= require cookies.min

#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates
#= require notifier
#= require_self

@App =
  showInfo:   (msg) -> $(document).trigger 'flash-info',   msg: msg
  showNotice: (msg) -> $(document).trigger 'flash-notice', msg: msg
  showAlert:  (msg) -> $(document).trigger 'flash-alert',  msg: msg

$ ->
  gutter = 2 # linkage to market.css.scss $gutter var
  gutter_2x = gutter * 2
  gutter_3x = gutter * 3
  gutter_4x = gutter * 4
  gutter_5x = gutter * 5
  gutter_6x = gutter * 6
  gutter_7x = gutter * 7
  gutter_8x = gutter * 8
  gutter_9x = gutter * 9

  nav_stacked_width = 50 # linkage to market.css.scss $nav_stacked_width var
  nav_stacked_width_2x = nav_stacked_width * 2

  panel_table_header_high = 73

  $(window).resize ->
    navbar_h = $('.navbar').height() + 1
    window_w = $(window).width()
    window_h = $(window).height()
    entry_h = $('#ask_entry').height()
    order_book_w = $('#order_book').width()

    $('.content').width(window_w)
    $('.content').height(window_h - navbar_h)

    $('#candlestick').width(window_w - order_book_w - gutter_3x - nav_stacked_width_2x)
    $('#candlestick').height(window_h - navbar_h - gutter_3x)

    $('#order_book').height(window_h - navbar_h - entry_h - gutter_5x)
    $('#order_book .panel-body-content').height(window_h - navbar_h - entry_h - panel_table_header_high - gutter_5x)


  $(window).resize()

  BigNumber.config(ERRORS: false)

  AccountBalanceUI.attachTo('.account-balance')
  MyOrdersUI.attachTo('#my_orders')
  MyDoneOrdersUI.attachTo('#my_done_orders')

  PlaceOrderUI.attachTo('#bid_entry')
  PlaceOrderUI.attachTo('#ask_entry')

  OrderBookUI.attachTo('#order_book')
  MarketTickerUI.attachTo('#ticker')
  MarketTradesUI.attachTo('#trades')
  MarketChartUI.attachTo('#candlestick')

  VerifyMobileNumberUI.attachTo('#new_token_sms_token')
  FlashMessageUI.attachTo('.flash-message')
  TwoFactorAuth.attachTo('.two-factor-auth-container')

  pusher = new Pusher gon.pusher.key,
    encrypted: gon.pusher.encrypted
    wsHost: gon.pusher.wsHost
    wsPort: gon.pusher.wsPort
    wssPort: gon.pusher.wssPort
  pusher.connection.bind 'state_change', (state) ->
    if state.current is 'unavailable'
      $('#markets-show .pusher-unavailable').removeClass('hide')

  GlobalData.attachTo(document, {pusher: pusher})
  MemberData.attachTo(document, {pusher: pusher}) if gon.accounts


  # TODO: move to place order component
  entry = '#ask_entry'
  $(document).on 'keyup', (e) ->
    if e.keyCode == 27
      if entry == '#bid_entry' then entry = '#ask_entry' else entry = '#bid_entry'
      $(entry).trigger 'place_order::clear'

  window.pusher = pusher

  notifier = window.notifier = new Notifier()
