@OrderInputMixin = ->

  @value = ->
    val = @$node.val()
    if $.isNumeric?(val)
      BigNumber(val)
    else
      null

  @newInput = (v) ->
    @trigger 'place_order::order::change', variables: @attr.variables, value: v

  @onChange = (event) ->
    if value = @value()
      @newInput value

  @after 'initialize', ->
    @on @$node, 'change paste keyup', @onChange
    @on "place_order::field::output", @onOutput
