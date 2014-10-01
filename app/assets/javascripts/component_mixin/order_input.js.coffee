@OrderInputMixin = ->

  @attributes
    form: null
    type: null

  @reset = ->
    @input = ''
    @value = null

  @getInputValue = ->
    val = @$node.val()
    return if val == @input

    if $.isNumeric?(val)
      @input = val
      BigNumber(val)
    else if val == '' # reset
      @reset()
      @changeOrder @value
      null
    else
      @$node.val @input
      null

  @setInputValue = (v) ->
    if v?
      @input = v.round(@attr.precision, BigNumber.ROUND_DOWN).toF(@attr.precision)
    else
      @input = ''

    @$node.val @input

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @inputToValue = (event) ->
    value = @getInputValue()
    return unless value

    if @validateRange(value)
      @changeOrder @value
    else
      @setInputValue @value

  @validateRange = (v) ->
    if @max && v.greaterThan(@max)
      @value = @max
      @changeOrder @max
      false
    else if v.lessThan(0)
      @value = null
      false
    else
      @value = v
      true

  @onInput = (event, data) ->
    @$node.val data[@attr.variables.input]
    @inputToValue()

  @onMax = (event, data) ->
    @max = data.max

  @after 'initialize', ->
    @orderType = @attr.type

    @reset()

    @on @$node, 'change paste keyup', @inputToValue
    @on @attr.form, "place_order::max::#{@attr.variables.input}", @onMax
    @on @attr.form, "place_order::input::#{@attr.variables.input}", @onInput
    @on @attr.form, "place_order::output::#{@attr.variables.input}", @onOutput
