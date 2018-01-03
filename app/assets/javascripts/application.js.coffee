#= require es5-shim.min
#= require es5-sham.min
#= require jquery
#= require jquery_ujs
#= require jquery-timing.min
#= require bootstrap
#= require bootstrap-switch.min
#= require scrollIt
#= require moment
#= require bignumber
#= require underscore
#= require clipboard
#= require flight.min
#= require pusher.min
#= require list
#= require jquery.mousewheel
#= require jquery-timing.min
#= require qrcode
#= require cookies.min

#= require ./lib/notifier
#= require ./lib/pusher_connection
#= require ./lib/tiny-pubsub

#= require highstock
#= require_tree ./highcharts/

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates

$ ->
  BigNumber.config(ERRORS: false)

  $('[data-clipboard-text], [data-clipboard-target]').each ->
      clipboard = new Clipboard(this)

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

  $('.qrcode-container').each (index, el) ->
    $el = $(el)
    new QRCode el,
      text:   $el.data('text')
      width:  $el.data('width')
      height: $el.data('height')

  FlashMessageUI.attachTo('.flash-message')
