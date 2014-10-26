COOKIE_KEY = 'range-unit'

@RangeSwitchUI = flight.component ->
  @attributes
    switch: 'a'

  @getUnit = ->
    if Cookies.get(COOKIE_KEY)
      return parseInt(Cookies.get(COOKIE_KEY))
    else
      return @setUnit(60)

  @setUnit = (unit) ->
    Cookies.set(COOKIE_KEY, unit)
    return unit

  @after 'initialize', ->
    @on @select('switch'), 'click', (e) =>
      @select('switch').removeClass('active')
      $(e.currentTarget).addClass('active')
      minutes = parseInt($(e.currentTarget).data('unit'))
      @setUnit(minutes)
      @trigger 'market::candlestick::request', {market: gon.market.id, minutes: minutes}

    unit = @getUnit()
    @$node.find("[data-unit=#{unit}]").click()
