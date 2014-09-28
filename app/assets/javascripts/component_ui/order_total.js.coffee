@OrderTotalUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'total'
      known: 'price'
      output: 'volume'

  @onOutput = (event, order) ->
    total = order.price.times order.volume

    if @orderType == 'bid' && total.greaterThan(@balance)
      total = @balance
      @changeOrder total

    @$node.val total
