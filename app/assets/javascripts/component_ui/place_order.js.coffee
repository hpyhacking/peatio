@PlaceOrderUI = flight.component ->
  @defaultAttrs
    formSel: 'form'
    successSel: 'span.label-success'
    infoSel: 'span.label-info'
    dangerSel: 'span.label-danger'

    sumSel: 'input[id$=sum]'
    priceSel: 'input[id$=price]'
    volumeSel: 'input[id$=volume]'

    lastPrice: '.last-price .value'
    currentBalanceSel: '.current-balance .value'
    submitButton: ':submit'

  @panelType = ->
    switch @$node.attr('id')
      when 'bid_panel' then 'bid'
      when 'ask_panel' then 'ask'

  @cleanMsg = ->
    @select('successSel').text('')
    @select('infoSel').text('')
    @select('dangerSel').text('')

  @resetForm = (event) ->
    @select('volumeSel').val BigNumber(0)
    @computeSum(event)

  @disableSubmit = (event, data) ->
    @select('submitButton').addClass('disabled').attr('disabled', 'disabled')

  @enableSubmit = (event, data) ->
    @select('submitButton').removeClass('disabled').removeAttr('disabled')

  @handleSuccess = (event, data) ->
    @cleanMsg()
    @select('successSel').text(data.message).show().fadeOut(3500)
    @resetForm(event)
    @enableSubmit()

  @handleError = (event, data) ->
    @cleanMsg()
    json = JSON.parse(data.responseText)
    @select('dangerSel').text(json.message).fadeOut(3500)
    @enableSubmit()

  @computeSum = (event) ->
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
      @trigger 'updateAvailable', {sum: sum, volume: volume}

  @computeVolume = (event) ->
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
      @trigger 'updateAvailable', {sum: sum, volume: volume}
      @trigger 'order', {price: price, sum: sum, volume: volume}

  @orderPlan = (event, data) ->
    return unless (@.$node.is(":visible"))
    @select('priceSel').val(data.price)
    @select('volumeSel').val(data.volume)
    @computeSum(event)

  @refreshPrice = (event, data) ->
    type = @panelType()
    switch type
      when 'bid'
        @select('lastPrice').text numeral(data.buy).format('0.00')
      when 'ask'
        @select('lastPrice').text numeral(data.sell).format('0.00')

  @refreshBalance = (event, data) ->
    type = @panelType()
    balance = data[type].balance
    @select('currentBalanceSel').text balance
    @select('currentBalanceSel').data('balance', balance)

  @updateAvailable = (event, data) ->
    type = @panelType()
    node = @select('currentBalanceSel')
    balance = BigNumber(node.data('balance'))
    switch type
      when 'bid'
        node.text(balance - data.sum)
      when 'ask'
        node.text(balance - data.volume)

  @after 'initialize', ->
    @on document, 'order::plan', @orderPlan
    @on document, 'market::ticker', @refreshPrice
    @on document, 'trade::account', @refreshBalance

    @on @select('formSel'), 'ajax:beforeSend', @disableSubmit
    @on @select('formSel'), 'ajax:success', @handleSuccess
    @on @select('formSel'), 'ajax:error', @handleError

    @on @select('sumSel'), 'change paste keyup', @computeVolume
    @on @select('priceSel'), 'change paste keyup', @computeSum
    @on @select('volumeSel'), 'change paste keyup', @computeSum

    @on @select('priceSel'), 'focusout', @computeSum
    @on @select('volumeSel'), 'focusout', @computeSum

    @on document, 'updateAvailable', @updateAvailable
