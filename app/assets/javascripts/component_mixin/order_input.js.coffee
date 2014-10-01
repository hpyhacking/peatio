@OrderInputMixin = ->

  @attributes
    form: null
    type: null

  @getInputValue = ->
    val = @$node.val()
    if val != @input && $.isNumeric?(val)
      @input = val
      BigNumber(val)
    else
      null

  @setInputValue = (v) ->
    if v?
      @input = v.round(@attr.precision, BigNumber.ROUND_DOWN).toF(@attr.precision)
    else
      @input = ''

    @$node.val @input

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @onInput = (event) ->
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

  @onMax = (event, data) ->
    @max = data.max

  @after 'initialize', ->
    @input     = ''
    @value     = null
    @orderType = @attr.type

    @on @$node, 'change paste keyup', @onInput
    @on @attr.form, "place_order::max::#{@attr.variables.input}", @onMax
    @on @attr.form, "place_order::output::#{@attr.variables.input}", @onOutput
