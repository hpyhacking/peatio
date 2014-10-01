@OrderPriceUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    precision: gon.market.bid.fixed
    variables:
      input: 'price'
      known: 'volume'
      output: 'total'

  @onOutput = (event, order) ->
    price = order.total.div order.volume
    @$node.val price
