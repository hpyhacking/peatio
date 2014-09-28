@OrderVolumeUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'volume'
      known: 'price'
      output: 'total'

  @constraintCheck = (v) ->
    if @orderType == 'ask' && v.greaterThan(@balance)
      @changeOrder @balance
      @$node.val @balance
      false
    else
      true

  @onInput = (event) ->
    value = @value()

    if value && @constraintCheck(value)
      @changeOrder value

  @onOutput = (event, order) ->
    volume = order.total.div order.price

    if @constraintCheck(volume)
      @$node.val volume
