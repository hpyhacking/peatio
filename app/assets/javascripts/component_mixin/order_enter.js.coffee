@OrderEnterMixin = ->
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

  @handleError = (event, data) ->
    @cleanMsg()
    json = JSON.parse(data.responseText)
    @select('dangerSel').text(json.message)
    @resetForm()

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

