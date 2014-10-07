@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    precision: gon.market.ask.fixed
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @onOutput = (event, order) ->
    volume = order.total.div order.price

    @changeOrder @value unless @validateRange(volume)
    @setInputValue @value

    order.volume = @value
    @trigger 'place_order::order::updated', order
