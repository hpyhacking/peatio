@OrderInputMixin = ->

  @attributes
    form: null
    type: null

  @getInputValue = ->
    val = @$node.val()
    if $.isNumeric?(val)
      BigNumber(val)
    else
      null

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @onInput = (event) ->
    value = @getInputValue()

    if value && @validateRange(value)
      @changeOrder value

  @validateRange = (v) ->
    if @max && v.greaterThan(@max)
      @changeOrder @max
      @$node.val @max
      false
    else if v.lessThan(0)
      @$node.val ''
      false
    else
      true

  @onMax = (event, data) ->
    @max = data.max

  @after 'initialize', ->
    @orderType = @attr.type

    @on @$node, 'change paste keyup', @onInput
    @on @attr.form, "place_order::max::#{@attr.variables.input}", @onMax
    @on @attr.form, "place_order::output::#{@attr.variables.input}", @onOutput
