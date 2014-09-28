@OrderPriceUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'price'
      known: 'volume'
      output: 'total'

  @onOutput = (event, order) ->
    price = order.total.div order.volume
    @$node.val price
