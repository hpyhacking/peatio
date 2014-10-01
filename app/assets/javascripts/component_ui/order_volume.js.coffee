@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @onOutput = (event, order) ->
    volume = order.total.div order.price

    @changeOrder @value unless @validateRange(volume)
    @setInputValue @value
