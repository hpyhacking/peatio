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
        date    = new Date(JSON.parse(root).timestamp)
        message = $(@).data('alert') + date

        if confirm(message)
          uri = 'http://syskall.com/proof-of-liabilities/#verify?partial_tree=' + partial_tree + '&expected_root=' + root
          window.open(encodeURI(uri), '_blank')

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

  # if gon.env is 'development'
  #   Pusher.log = (message) ->
  #     window.console && console.log(message)

  AccountBalanceUI.attachTo('.account-balance')
  OrderEnterUI.attachTo('.order-enter #bid_panel')
  OrderEnterUI.attachTo('.order-enter #ask_panel')
  MyOrdersWaitUI.attachTo('.my-orders #orders_wait')
  MyOrdersDoneUI.attachTo('.my-orders #orders_done')
  PushButton.attachTo('.order-enter')
  PushButton.attachTo('.my-orders')

  MarketTickerUI.attachTo('.ticker')
  MarketOrdersUI.attachTo('.orders')
  MarketTradesUI.attachTo('.trades')
  MarketChartUI.attachTo('.price-chart')

  pusher = new Pusher(gon.pusher_key, {encrypted: true})
  GlobalData.attachTo(document, {pusher: pusher})
  AccountData.attachTo(document, {pusher: pusher}) if gon.accounts
  OrderData.attachTo(document, {pusher: pusher}) if gon.current_user

