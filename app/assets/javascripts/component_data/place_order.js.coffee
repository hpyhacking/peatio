@PlaceOrderData = flight.component ->

  @solve = ->
    return unless @order[@known] && @order.balance
    @trigger document, "place_order::solve::#{@output}", @order

  @setOrder = (event, data) ->
    {input: @input, known: @known, output: @output} = data.variables
    @order[@input] = data.value
    @solve()

  @setBalance = (event, data) ->
    @order.balance = data.balance

  @after 'initialize', ->
    @order = {price: null, volume: null, total: null, balance: null}

    @on document, 'place_order::order::change', @setOrder
    @on document, 'place_order::balance::change', @setBalance
