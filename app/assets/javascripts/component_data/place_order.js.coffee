@PlaceOrderData = flight.component ->

  @setOrder = (event, data) ->
    {input: @input, known: @known, output: @output} = data.variables
    @order[@input] = data.value

    return unless @order[@known] && @order.balance
    @trigger "place_order::order::output", output: @output, order: @order

  @setBalance = (event, data) ->
    @order.balance = data.balance

  @after 'initialize', ->
    @order = {price: null, volume: null, total: null, balance: null}

    @on 'place_order::order::change', @setOrder
    @on 'place_order::balance::change', @setBalance
