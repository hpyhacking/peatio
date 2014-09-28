@OrderTotalUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'total'
      known: 'price'
      output: 'volume'

  @onInput = (event, order) ->

  @onOutput = (event, order) ->
    total = order.price.times order.volume

    if order.type == 'bid' && total.greaterThan(order.balance)
      total = order.balance
      @changeOrder total

    @$node.val total
