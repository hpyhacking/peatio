window.MarketTickerUI = flight.component ->
  @attributes
    askSelector: '.ask .price'
    bidSelector: '.bid .price'
    lastSelector: '.last .price'
    priceSelector: '.price'

  @updatePrice = (selector, price, trend) ->
    selector.removeClass('text-up').removeClass('text-down').addClass(formatter.trend(trend))
    selector.html(formatter.fixBid(price))

  @refresh = (event, ticker) ->
    @updatePrice @select('askSelector'),  ticker.sell, ticker.sell_trend
    @updatePrice @select('bidSelector'),  ticker.buy,  ticker.buy_trend
    @updatePrice @select('lastSelector'), ticker.last, ticker.last_trend

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
