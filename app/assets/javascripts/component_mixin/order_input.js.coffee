@OrderInputMixin = ->

  @attributes
    form: null
    type: null

  @parseText = ->
    text = @$node.val()
    return false if text == @text

    if text == ''
      @text = ''
      @value = null
      @changeOrder @value
      return false

    if $.isNumeric(text)
      value = BigNumber(text)
      precision = value.c.length - value.e - 1
      if precision > @attr.precision
        @$node.val @text
        false
      else
        @text = text
        @value = value
        true
    else
      @$node.val @text
      false

  @setInputValue = (v) ->
    if v?
      @text = v.round(@attr.precision, BigNumber.ROUND_DOWN).toF(@attr.precision)
    else
      @text = ''

    @$node.val @text

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @textToValue = (event) ->
    return unless @parseText()

    if @validateRange(@value)
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
    @textToValue()

  @onMax = (event, data) ->
    @max = data.max

  @after 'initialize', ->
    @orderType = @attr.type
    @text     = ''
    @value     = null

    @on @$node, 'change paste keyup', @textToValue
    @on @attr.form, "place_order::max::#{@attr.variables.input}", @onMax
    @on @attr.form, "place_order::input::#{@attr.variables.input}", @onInput
    @on @attr.form, "place_order::output::#{@attr.variables.input}", @onOutput
