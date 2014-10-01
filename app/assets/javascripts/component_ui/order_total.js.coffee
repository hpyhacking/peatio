@OrderTotalUI = flight.component ->
  flight.compose.mixin @, [OrderInputMixin]

  @attributes
    precision: gon.market.bid.fixed
    variables:
      input: 'total'
      known: 'price'
      output: 'volume'

  @onOutput = (event, order) ->
    total = order.price.times order.volume

    @changeOrder @value unless @validateRange(total)
    @setInputValue @value
