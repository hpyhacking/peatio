@ChartSwitchUI = flight.component ->
  @attributes
    switch: 'a'

  @getUnit = ->
    if Cookies.get('chart-unit')
      return parseInt(Cookies.get('chart-unit'))
    else
      return @setUnit(60)

  @setUnit = (unit) ->
    Cookies.set('chart-unit', unit)
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
