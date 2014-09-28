@OrderInputMixin = ->

  @value = ->
    val = @$node.val()
    if $.isNumeric?(val)
      BigNumber(val)
    else
      null

  @onChange = (event) ->
    if value = @value()
      @trigger "place_order::order::change", variables: @attr.variables, value: value

  @after 'initialize', ->
    @on @$node, 'change paste keyup', @onChange
    @on document, "place_order::solve::#{@attr.variables.input}", @solve
