@OrderInputMixin = ->

  @value = ->
    val = @$node.val()
    if $.isNumeric?(val)
      BigNumber(val)
    else
      null

  @changeOrder = (v) ->
    @trigger 'place_order::order::change', variables: @attr.variables, value: v

  @onInput = (event) ->
    if value = @value()
      @changeOrder value

  @after 'initialize', ->
    console.log arguments
    console.log @attr
    @on @$node, 'change paste keyup', @onInput
    @on "place_order::field::output", @onOutput
