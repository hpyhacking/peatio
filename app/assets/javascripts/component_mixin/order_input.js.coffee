@OrderInputMixin = ->

  @attributes
    form: null
    type: null

  @reset = ->
    @text = ''
    @value = BigNumber('0')
    @changeOrder @value

  @rollback = ->
    @$node.val @text

  @parseText = ->
    text  = @$node.val()
    value = BigNumber(text)

    switch
      when text == @text
        false
      when text == ''
        @reset()
        false
      when !$.isNumeric(text)
        @rollback()
        false
      when (value.c.length - value.e - 1) > @attr.precision
        @rollback()
        false
      else
        @text = text
        @value = value
        true

  @roundValueToText = (v) ->
    v.round(@attr.precision, BigNumber.ROUND_DOWN).toF(@attr.precision)

  @setInputValue = (v) ->
    if v?
      @text = @roundValueToText(v)
    else
      @text = ''

    @$node.val @text

  @changeOrder = (v) ->
    @trigger 'place_order::input', variables: @attr.variables, value: v

  @process = (event) ->
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
    @$node.val @roundValueToText(data[@attr.variables.input])
    @process()

  @onMax = (event, data) ->
    @max = data.max

  @onReset = (event) ->
    @$node.val ''
    @reset()

  @after 'initialize', ->
    @orderType = @attr.type
    @text      = ''
    @value     = null

    @on @$node, 'change paste keyup', @process
    @on @attr.form, "place_order::max::#{@attr.variables.input}", @onMax
    @on @attr.form, "place_order::input::#{@attr.variables.input}", @onInput
    @on @attr.form, "place_order::output::#{@attr.variables.input}", @onOutput
    @on @attr.form, "place_order::reset::#{@attr.variables.input}", @onReset
