@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @onOutput = (event, order) ->
    volume = order.total.div order.price

    if @orderType == 'ask' && volume.greaterThan(@balance)
      volume = @balance
      @changeOrder volume

    @$node.val volume
