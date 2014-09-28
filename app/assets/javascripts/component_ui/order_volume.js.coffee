@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @onOutput = (event, order) ->
    volume = order.total.div order.price

    if order.type == 'ask' && volume.greaterThan(order.balance)
      volume = order.balance
      @changeOrder volume

    @$node.val volume
