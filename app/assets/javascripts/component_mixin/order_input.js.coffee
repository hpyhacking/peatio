@OrderInputMixin = ->

  @attributes
    parent: null

  @value = ->
    val = @$node.val()
    if $.isNumeric?(val)
      BigNumber(val)
    else
      null

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @onInput = (event) ->
    if value = @value()
      @changeOrder value

  @setBalance = (event, data) ->
    @balance = data.balance

  @after 'initialize', ->
    @orderType = @attr.parent.panelType()

    @on @$node, 'change paste keyup', @onInput
    @on @attr.parent.$node, "place_order::output::#{@attr.variables.input}", @onOutput
    @on @attr.parent.$node, "place_order::balance::change", @setBalance
