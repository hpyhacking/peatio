window.MarketTickerUI = flight.component ->
  @.lastPrice = 0

  @attributes
    latestPriceSelector: 'td.last'
    highPriceSelector: 'td.high'
    lowPriceSelector: 'td.low'
    volumeSelector: 'td.volume'
    askPriceSelector: 'td.sell'
    bidPriceSelector: 'td.buy'

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

  @refresh = (event, data) ->
    @select('volumeSelector').text round(data.volume, gon.market.ask.fixed)

    @update @select('askPriceSelector'), data.sell
    @update @select('bidPriceSelector'), data.buy
    @update @select('lowPriceSelector'), data.low
    @update @select('highPriceSelector'), data.high

    old = @select('latestPriceSelector').text()
    old = 0 if old == "" 
    trend = BigNumber(data.last).greaterThan(BigNumber(old))

    @update @select('latestPriceSelector'), data.last, trend

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
