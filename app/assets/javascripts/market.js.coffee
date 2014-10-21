#= require es5-shim.min
#= require es5-sham.min
#= require jquery
#= require jquery_ujs
#= require jquery.mousewheel
#= require jquery-timing.min
#
#= require bootstrap
#= require bootstrap-switch.min
#
#= require moment
#= require bignumber
#= require underscore
#= require cookies.min
#= require handlebars.runtime
#= require helper
#= require flight.min
#= require pusher.min
#= require highstock
#= require highstock_config
#= require notifier

#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates
#= require_self

$ ->
  BigNumber.config(ERRORS: false)

  KeyBindUI.attachTo(document)
  AutoWindowUI.attachTo(window)
  PlaceOrderUI.attachTo('#bid_entry')
  PlaceOrderUI.attachTo('#ask_entry')
  OrderBookUI.attachTo('#order_book')
  CandlestickUI.attachTo('#candlestick')
  HeaderUI.attachTo('header')

  AccountBalanceUI.attachTo('.account-balance')
  MyOrdersUI.attachTo('#my_orders')
  MyDoneOrdersUI.attachTo('#my_done_orders')
  MarketTickerUI.attachTo('#ticker')
  MarketSwitchUI.attachTo('#market_swtich')
  MarketTradesUI.attachTo('#market_trades')
  FlashMessageUI.attachTo('.flash-message')

  FloatUI.attachTo('.float')

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

  window.sfx = (kind) ->
    s = $("##{kind}-fx")[0]
    return unless s.play
    s.pause()
    s.currentTime = 0
    s.play()

  window.sfx_warning = ->
    window.sfx('warning')

  window.sfx_success = ->
    window.sfx('success')

  window.pusher = pusher
  notifier = window.notifier = new Notifier()

# TODO: unknown code
#@App =
  #showInfo:   (msg) -> $(document).trigger 'flash-info',   msg: msg
  #showNotice: (msg) -> $(document).trigger 'flash-notice', msg: msg
  #showAlert:  (msg) -> $(document).trigger 'flash-alert',  msg: msg

