@PlaceOrderData = flight.component ->

  @onInput = (event, data) ->
    {input: @input, known: @known, output: @output} = data.variables
    @order[@input] = data.value

    return unless @order[@known] && @order.balance
    @trigger "place_order::output::#{@output}", @order

  @setBalance = (event, data) ->
    @order.balance = data.balance

  @after 'initialize', ->
    @order = {price: null, volume: null, total: null, balance: null}

    @on 'place_order::input', @onInput
    @on 'place_order::balance::change', @setBalance
