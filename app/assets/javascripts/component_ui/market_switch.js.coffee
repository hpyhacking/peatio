window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @updateMarket = (select, ticker) ->
    trend = formatter.trend ticker.last_trend
    select.find('td.price').html("<span class='#{trend}'>#{formatter.ticker_price ticker.last}</span>")
    select.find('td.change').html("<span class='#{trend}'>+11.21</span>")

  @refresh = (event, data) ->
    tickers = _.sortBy data.tickers, (ticker) ->
      gon.market_orders[ticker.market]

    table = @select('table')
    for ticker in tickers.reverse()
      @updateMarket table.find("tr#market-list-#{ticker.market}"), ticker.data

    table.find("tr#market-list-#{gon.market.id}").addClass 'highlight'

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
