@PlaceOrderData = flight.component ->

  @solve = ->
    return unless @order[@known]
    @trigger document, "place_order::solve::#{@output}", @order

  @onData = (event, data) ->
    {input: @input, known: @known, output: @output} = data.variables
    @order[@input] = data.value
    @solve()

  @after 'initialize', ->
    @order = {price: null, volume: null, total: null}

    @on document, 'place_order::data', @onData
