window.MarketTickerUI = flight.component ->
  @defaultAttrs
    volumeSelector: '.value.volume'
    askPriceSelector: '.value.sell'
    bidPriceSelector: '.value.buy'
    lowPriceSelector: '.value.low'
    highPriceSelector: '.value.high'
    latestPriceSelector: '.value.last'

  @update = (el, text) ->
    text = numeral(text).format('0.00')
    if el.text() isnt text
      el.fadeOut ->
        el.text(text).fadeIn()

  @refresh = (event, data) ->
    @update @select('volumeSelector'), data['volume']
    @update @select('askPriceSelector'), data['sell']
    @update @select('bidPriceSelector'), data['buy']
    @update @select('lowPriceSelector'), data['low']
    @update @select('highPriceSelector'), data['high']
    @update @select('latestPriceSelector'), data['last']

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
