@PlaceOrderData = flight.component ->

  @onInput = (event, data) ->
    {input: @input, known: @known, output: @output} = data.variables
    @order[@input] = data.value

    return unless @order[@input] && @order[@known]
    @trigger "place_order::output::#{@output}", @order

  @after 'initialize', ->
    @order = {price: null, volume: null, total: null}

    @on 'place_order::input', @onInput
