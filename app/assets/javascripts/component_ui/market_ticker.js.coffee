window.MarketTickerUI = flight.component ->
  @attributes
    volumeSelector: '.value.volume'
    askPriceSelector: '.value.sell'
    bidPriceSelector: '.value.buy'
    lowPriceSelector: '.value.low'
    highPriceSelector: '.value.high'
    latestPriceSelector: '.value.last'

  @update = (el, text) ->
    text = round(text, gon.market.bid.fixed)
    if el.text() isnt text
      el.fadeOut ->
        el.text(text).fadeIn()

  @refresh = (event, data) ->
    @select('volumeSelector').text round(data.volume, gon.market.ask.fixed)

    @update @select('askPriceSelector'), data.sell
    @update @select('bidPriceSelector'), data.buy
    @update @select('lowPriceSelector'), data.low
    @update @select('highPriceSelector'), data.high
    @update @select('latestPriceSelector'), data.last

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
