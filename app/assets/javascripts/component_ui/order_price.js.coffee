@OrderPriceUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'price'
      known: 'volume'
      output: 'total'

  @solve = (event, data) ->
    price = data.total.div data.volume
    @$node.val price
