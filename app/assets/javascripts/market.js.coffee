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
#= require flight.min
#= require pusher.min

#= require ./lib/sfx
#= require ./lib/notifier
#= require ./lib/pusher_connection

#= require highstock
#= require_tree ./highcharts/

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates

#= require_self

$ ->
  BigNumber.config(ERRORS: false)

  FloatUI.attachTo('.float')
  HeaderUI.attachTo('header')
  KeyBindUI.attachTo(document)
  AutoWindowUI.attachTo(window)
  PlaceOrderUI.attachTo('#bid_entry')
  PlaceOrderUI.attachTo('#ask_entry')
  OrderBookUI.attachTo('#order_book')
  DepthUI.attachTo('#depths')

  AccountBalanceUI.attachTo('.account-balance')
  MyOrdersUI.attachTo('#my_orders')
  MyDoneOrdersUI.attachTo('#my_done_orders')
  MarketTickerUI.attachTo('#ticker')
  MarketSwitchUI.attachTo('#market_swtich')
  MarketTradesUI.attachTo('#market_trades')
  FlashMessageUI.attachTo('.flash-message')

  MarketData.attachTo(document)
  GlobalData.attachTo(document, {pusher: window.pusher})
  MemberData.attachTo(document, {pusher: window.pusher}) if gon.accounts

  CandlestickUI.attachTo('#candlestick')
  ChartSwitchUI.attachTo('#chart_switch')

  window.notifier = new Notifier()
