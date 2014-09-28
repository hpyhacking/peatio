@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @solve = (event, data) ->
    volume = data.total.div data.price
    @$node.val volume
