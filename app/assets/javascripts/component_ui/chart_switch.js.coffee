@ChartSwitchUI = flight.component ->
  @attributes
    switch: 'a'

  @after 'initialize', ->
    @on @select('switch'), 'click', (e) =>
      @select('switch').removeClass('active')
      $(e.currentTarget).addClass('active')
      minutes = parseInt($(e.currentTarget).data('unit'))

      @trigger 'market::candlestick::request', {market: gon.market.id, minutes: minutes}
    @$node.find('[data-unit=60]').click()
