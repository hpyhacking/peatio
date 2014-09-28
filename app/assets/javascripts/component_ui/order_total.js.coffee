@OrderTotalUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'total'
      known: 'price'
      output: 'volume'

  @onOutput = (event, order) ->
    total = order.price.times order.volume

    if order.type == 'bid' && total.greaterThan(order.balance)
      total = order.balance
      @newInput total

    @$node.val total
