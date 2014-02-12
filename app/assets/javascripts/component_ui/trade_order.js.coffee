window.TradeOrderUI = flight.component ->
  @.defaultAttrs
    formSel: 'form',
    labelSel: 'span.label-success',
    infoSel: 'span.label-info',
    dangerSel: 'span.label-important',

    sumSel: 'input[id$=sum]',
    priceSel: 'input[id$=price]',
    volumeSel: 'input[id$=volume]',

    groupsSel: 'form > div.control-group',
    controlsSel: 'form > div.control-group > div.controls',

    sumGroupSel: 'form > div.control-group[class*=sum]'
    priceGroupSel: 'form > div.control-group[class*=price]'
    origin_volumeGroupSel: 'form > div.control-group[class*=origin_volume]'

  @.refreshPrice = (event, price) ->
    @.select('priceSel').val(price || gon.ticker.last)

  @.computeVolume = (target) ->
    if @.select('priceSel').val() and @.select('sumSel').val()

      unless @.select('priceSel').is(target)
        @.select('priceSel').fixBid()
      unless @.select('sumSel').is(target)
        @.select('sumSel').fixBid()

      sum = BigNumber(@.select('sumSel').val())
      price = BigNumber(@.select('priceSel').val())
      volume = sum.dividedBy(price)
      @.select('volumeSel').val(volume).fixAsk()
      @.trigger 'order', {price: price, sum: sum, volume: volume}
      @.info(volume, price)
    else
      @.trigger 'order_empty'
      @.info()

  @.computeSum = (target) ->
    if @.select('priceSel').val() and @.select('volumeSel').val()

      unless @.select('priceSel').is(target)
        @.select('priceSel').fixBid()
      unless @.select('volumeSel').is(target)
        @.select('volumeSel').fixAsk()

      price = BigNumber(@.select('priceSel').val())
      volume = BigNumber(@.select('volumeSel').val())
      sum = price.times(volume)
      @.select('sumSel').val(sum).fixBid()
      @.trigger 'order', {price: price, sum: sum, volume: volume}
      @.info(volume, price)
    else
      @.trigger 'order_empty'
      @.info()

  @.info = (volume, price) ->
    if volume and price
      @.select('infoSel').text("#{fixAsk volume} @ #{fixBid price}")
    else
      @.select('infoSel').text("")

  @.orderSuccess = (event, data) ->
    @.select('groupsSel').removeClass('error').find('span.help-inline').empty()
    @.select('labelSel').text(data.message)
    @.select('dangerSel').text("")

  @.orderError = (event, data) ->
    json = JSON.parse(data.responseText)
    for field, errors of json.errors
      @.select("#{field}GroupSel").addClass('error').find('span.help-inline').text(errors.join())
    @.select('labelSel').text("")
    @.select('dangerSel').text(json.message)

  @.after 'initialize', ->
    @.on 'price', @.refreshPrice
    @.select('sumSel').on 'change paste keyup', (e) => @.computeVolume(e.currentTarget)
    @.select('priceSel').on 'change paste keyup', (e) => @.computeSum(e.currentTarget)
    @.select('volumeSel').on 'change paste keyup', (e) => @.computeSum(e.currentTarget)
    @.select('priceSel').on 'focusout', => @.computeSum()
    @.select('volumeSel').on 'focusout', => @.computeSum()

    @.select('formSel').on 'ajax:success', (e, d) => @.orderSuccess(e, d)
    @.select('formSel').on 'ajax:error', (e, d) => @.orderError(e, d)
    @.select('controlsSel').append "<span class='help-inline'></span>"

    @.on document, 'order::plan', (event, data) =>
      return unless (@.$node.is(":visible"))
      @.select('priceSel').val(data.price)
      @.select('volumeSel').val(data.volume)
      @.computeSum()
      @.info(data.volume, data.avg_price)
