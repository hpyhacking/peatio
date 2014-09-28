@OrderTotalUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    variables:
      input: 'total'
      known: 'price'
      output: 'volume'

  @constraintCheck = (v) ->
    if @orderType == 'bid' && v.greaterThan(@balance)
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
    total = order.price.times order.volume

    if @constraintCheck(total)
      @$node.val total
