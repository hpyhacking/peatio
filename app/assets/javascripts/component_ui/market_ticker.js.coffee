window.MarketTickerUI = flight.component ->
  @.lastPrice = 0

  @attributes
    latestPriceSelector: 'td.last'
    highPriceSelector: 'td.high'
    lowPriceSelector: 'td.low'
    volumeSelector: 'td.volume'
    bidPriceSelector: 'td.bid'
    askPriceSelector: 'td.ask'

  @update = (el, text, trend) ->
    text = round(text, gon.market.bid.fixed)
    if el.text() isnt text
      el.fadeOut ->
        if trend?
          if trend
            el.removeClass("text-down").addClass("text-up").text(text).fadeIn()
          else
            el.removeClass("text-up").addClass("text-down").text(text).fadeIn()
        else
          el.text(text).fadeIn()

  @checkTrend = (data) ->
    old = @select(data[1]).text()
    old = 0 if old == "" 
    trend = BigNumber(data[0]).greaterThan(BigNumber(old))
    @update @select(data[1]), data[0], trend

  @refresh = (event, data) ->
    @select('volumeSelector').text round(data.volume, gon.market.ask.fixed)

    @update @select('askPriceSelector'), data.sell
    @update @select('bidPriceSelector'), data.buy
    @update @select('lowPriceSelector'), data.low
    @update @select('highPriceSelector'), data.high

    @checkTrend d for d in [[data.last, 'latestPriceSelector'], [data.buy, 'bidPriceSelector'], [data.sell, 'askPriceSelector']]

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
