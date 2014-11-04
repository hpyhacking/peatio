window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @refresh = (event, data) ->
    $table = @select('table').empty()

    tickers = _.sortBy data.tickers, (ticker) ->
      gon.market_orders[ticker.market]

    for ticker in tickers.reverse()
      ticker['current'] = true if (ticker.market == gon.market.id)
      $table.prepend(JST['templates/market_switch'](ticker))

  @after 'initialize', ->
    @on document, 'market::tickers', @refresh
    @select('table').on 'click', 'tr', (e) ->
      unless e.target.nodeName == 'I'
        window.location.href = window.formatter.market_url($(@).data('market'))

    @.hide_accounts = $('tr.hide')
    $('.view_all_accounts').on 'click', (e) =>
      $el = $(e.currentTarget)
      if @.hide_accounts.hasClass('hide')
        $el.text($el.data('hide-text'))
        @.hide_accounts.removeClass('hide')
      else
        $el.text($el.data('show-text'))
        @.hide_accounts.addClass('hide')
