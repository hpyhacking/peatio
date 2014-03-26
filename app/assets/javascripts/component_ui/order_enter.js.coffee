@OrderEnterUI = flight.component ->
  @defaultAttrs
    formSel: 'form'
    successSel: 'span.label-success'
    infoSel: 'span.label-info'
    dangerSel: 'span.label-danger'

    sumSel: 'input[id$=sum]'
    priceSel: 'input[id$=price]'
    volumeSel: 'input[id$=volume]'

  @cleanMsg = ->
    @select('successSel').text('')
    @select('infoSel').text('')
    @select('dangerSel').text('')

  @resetForm = ->
    @select('volumeSel').val BigNumber(0)
    @computeSum()

  @handleSuccess = (event, data) ->
    @cleanMsg()
    @select('successSel').text(data.message)
    @resetForm()

  @handleError = (event, data) ->
    @cleanMsg()
    json = JSON.parse(data.responseText)
    @select('dangerSel').text(json.message)

  @computeSum = (e) ->
    if @select('priceSel').val() and @select('volumeSel').val()

      target = event.target
      if not @select('priceSel').is(target)
        @select('priceSel').fixBid()

      if not @select('volumeSel').is(target)
        @select('volumeSel').fixAsk()

      price  = BigNumber(@select('priceSel').val())
      volume = BigNumber(@select('volumeSel').val())
      sum    = price.times(volume)

      @select('sumSel').val(sum).fixBid()

  @computeVolume = (e) ->
    if @.select('priceSel').val() and @.select('sumSel').val()

      target = event.target
      if not @select('priceSel').is(target)
        @select('priceSel').fixBid()
      if not @select('sumSel').is(target)
        @select('sumSel').fixBid()

      sum    = BigNumber(@select('sumSel').val())
      price  = BigNumber(@select('priceSel').val())
      volume = sum.dividedBy(price)

      @select('volumeSel').val(volume).fixAsk()
      @trigger 'order', {price: price, sum: sum, volume: volume}

  @orderPlan = (event, data) ->
    return unless (@.$node.is(":visible"))
    @.select('priceSel').val(data.price)
    @.select('volumeSel').val(data.volume)
    @.computeSum()

  @refreshPrice = (event, price) ->
    @select('priceSel').val(price || gon.ticker.last)

  @after 'initialize', ->
    @on document, 'order::plan', @orderPlan
    @on document, 'market::price::bid', @refreshPrice

    @on @select('formSel'), 'ajax:success', @handleSuccess
    @on @select('formSel'), 'ajax:error', @handleError

    @on @select('sumSel'), 'change paste keyup', @computeVolume
    @on @select('priceSel'), 'change paste keyup', @computeSum
    @on @select('volumeSel'), 'change paste keyup', @computeSum

    @on @select('priceSel'), 'focusout', @computeSum
    @on @select('volumeSel'), 'focusout', @computeSum
