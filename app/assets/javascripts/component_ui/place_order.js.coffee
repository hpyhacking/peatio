@PlaceOrderUI = flight.component ->
  @attributes
    formSel: 'form'
    successSel: '.status span.label-success'
    infoSel: '.status span.label-info'
    dangerSel: '.status span.label-danger'
    priceAlertSel: '.price-alert span.label-danger'

    priceSel: 'input[id$=price]'
    volumeSel: 'input[id$=volume]'
    sumSel: 'input[id$=total]'

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
    @select('sumSel').val BigNumber(0)

  @disableSubmit = ->
    @select('submitButton').addClass('disabled').attr('disabled', 'disabled')

  @enableSubmit = ->
    @select('submitButton').removeClass('disabled').removeAttr('disabled')

  @confirmDialogMsg = ->
    confirmType = @select('submitButton').text()
    price = @select('priceSel').val()
    volume = @select('volumeSel').val()
    sum = @select('sumSel').val()
    """
    #{gon.i18n.place_order.confirm_submit} "#{confirmType}"?

    #{gon.i18n.place_order.price}: #{price}
    #{gon.i18n.place_order.volume}: #{volume}
    #{gon.i18n.place_order.sum}: #{sum}
    """

  @beforeSend = (event, jqXHR) ->
    if confirm(@confirmDialogMsg())
      @disableSubmit()
    else
      jqXHR.abort()

  @handleSuccess = (event, data) ->
    @cleanMsg()
    @select('successSel').text(data.message).show().fadeOut(3500)
    @resetForm(event)
    @enableSubmit()

  @handleError = (event, data) ->
    @cleanMsg()
    json = JSON.parse(data.responseText)
    @select('dangerSel').text(json.message).show().fadeOut(3500)
    @enableSubmit()

  @solveEquation = (target, price, vol, sum, balance) ->
    if !price
      price = sum.dividedBy(vol)
    else if !vol
      vol = sum.dividedBy(price)
    else if !sum
      sum = price.times(vol)

    if sum.greaterThan(balance)
      [price, vol, sum] = @solveEquation(target, price, null, balance, balance)
      @select('sumSel').val(sum)
      @select('volumeSel').val(vol)

    if vol.greaterThan(balance)
      [price, vol, sum] = @solveEquation(target, price, balance, null, balance)
      @select('sumSel').val(sum)
      @select('volumeSel').val(vol)

    [price, vol, sum]

  @getBalance = ->
    BigNumber( @select('currentBalanceSel').data('balance') )

  @getPrice = ->
    BigNumber( @select('priceSel').val() )

  @getVolume = ->
    BigNumber( @select('volumeSel').val() )

  @getSum = ->
    BigNumber( @select('sumSel').val() )

  @sanitize = (el) ->
    el.val '' if !$.isNumeric(el.val())

  @computeSum = (event) ->
    @sanitize @select('priceSel')
    @sanitize @select('volumeSel')

    target = event.target
    if not @select('priceSel').is(target)
      @select('priceSel').fixBid()
    if not @select('volumeSel').is(target)
      @select('volumeSel').fixAsk()

    [price, volume, sum] = @solveEquation(target, @getPrice(), @getVolume(), null, @getBalance())

    @select('sumSel').val(sum).fixBid()
    @trigger 'updateAvailable', {sum: sum, volume: volume}

  @computeVolume = (event) ->
    @sanitize @select('priceSel')
    @sanitize @select('sumSel')

    target = event.target
    if not @select('priceSel').is(target)
      @select('priceSel').fixBid()
    if not @select('sumSel').is(target)
      @select('sumSel').fixAsk()

    [price, volume, sum] = @solveEquation(target, @getPrice(), null, @getSum(), @getBalance())

    @select('volumeSel').val(volume).fixAsk()
    @trigger 'updateAvailable', {sum: sum, volume: volume}

  @orderPlan = (event, data) ->
    return unless (@.$node.is(":visible"))
    @select('priceSel').val(data.price)
    @select('volumeSel').val(data.volume)
    @computeSum(event)

  @refreshBalance = (event, data) ->
    type = @panelType()
    currency = gon.market[type].currency
    balance = gon.accounts[currency].balance
    @select('currentBalanceSel').data('balance', balance)
    switch type
      when 'bid'
        @select('currentBalanceSel').text(balance).fixBid()
      when 'ask'
        @select('currentBalanceSel').text(balance).fixAsk()

  @updateAvailable = (event, data) ->
    type = @panelType()
    node = @select('currentBalanceSel')

    switch type
      when 'bid'
        node.text(@getBalance() - data.sum).fixBid()
      when 'ask'
        node.text(@getBalance() - data.volume).fixAsk()

  @updateLastPrice = (event, data) ->
    @select('lastPrice').text data.last

  @copyLastPrice = ->
    lastPrice = @select('lastPrice').text().trim()
    @select('priceSel').val(lastPrice).focus()

  @priceCheck = (event) ->
    currentPrice = Number @select('priceSel').val()
    lastPrice = Number gon.ticker.last
    priceAlert = @select('priceAlertSel')

    switch
      when currentPrice > (lastPrice * 1.1)
        priceAlert.text gon.i18n.place_order.price_high
      when currentPrice < (lastPrice * 0.9)
        priceAlert.text gon.i18n.place_order.price_low
      else
        priceAlert.text ''


  @after 'initialize', ->
    @on document, 'order::plan', @orderPlan
    @on document, 'market::ticker', @updateLastPrice
    @on 'updateAvailable', @updateAvailable

    @on document, 'account::update', @refreshBalance
    @on @select('lastPrice'), 'click', @copyLastPrice
    @updateLastPrice 'market::ticker', gon.ticker

    @on @select('formSel'), 'ajax:beforeSend', @beforeSend
    @on @select('formSel'), 'ajax:success', @handleSuccess
    @on @select('formSel'), 'ajax:error', @handleError

    @on @select('priceSel'), 'focusout', @priceCheck
    @on @select('priceSel'), 'change paste keyup focusout', @computeSum
    @on @select('volumeSel'), 'change paste keyup focusout', @computeSum
    @on @select('sumSel'), 'change paste keyup focusout', @computeVolume

