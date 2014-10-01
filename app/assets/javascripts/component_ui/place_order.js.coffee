@PlaceOrderUI = flight.component ->
  @attributes
    formSel: 'form'
    successSel: '.status-success'
    infoSel: '.status-info'
    dangerSel: '.status-danger'
    priceAlertSel: '.hint-price-disadvantage'
    positionsLabelSel: '.hint-positions'

    priceSel: 'input[id$=price]'
    volumeSel: 'input[id$=volume]'
    totalSel: 'input[id$=total]'

    currentBalanceSel: 'span.current-balance'
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
    @select('totalSel').val BigNumber(0)

  @disableSubmit = ->
    @select('submitButton').addClass('disabled').attr('disabled', 'disabled')

  @enableSubmit = ->
    @select('submitButton').removeClass('disabled').removeAttr('disabled')

  @confirmDialogMsg = ->
    confirmType = @select('submitButton').text()
    price = @select('priceSel').val()
    volume = @select('volumeSel').val()
    sum = @select('totalSel').val()
    """
    #{gon.i18n.place_order.confirm_submit} "#{confirmType}"?

    #{gon.i18n.place_order.price}: #{price}
    #{gon.i18n.place_order.volume}: #{volume}
    #{gon.i18n.place_order.sum}: #{sum}
    """

  @beforeSend = (event, jqXHR) ->
    if true #confirm(@confirmDialogMsg())
      @disableSubmit()
    else
      jqXHR.abort()

  @handleSuccess = (event, data) ->
    @cleanMsg()
    @select('successSel').text(data.message).show().fadeOut(2500)
    @resetForm(event)
    @enableSubmit()

  @handleError = (event, data) ->
    @cleanMsg()
    json = JSON.parse(data.responseText)
    @select('dangerSel').text(json.message).show().fadeOut(2500)
    @enableSubmit()

  @solveEquation = (price, vol, sum, balance) ->
    if !vol && !price.equals(0)
      vol = sum.dividedBy(price)
    else if !sum
      sum = price.times(vol)

    type = @panelType()
    if type == 'bid' && sum.greaterThan(balance)
      [price, vol, sum] = @solveEquation(price, null, balance, balance)
      @select('totalSel').val(sum).fixBid()
      @select('volumeSel').val(vol).fixAsk()
    else if type == 'ask' && vol.greaterThan(balance)
      [price, vol, sum] = @solveEquation(price, balance, null, balance)
      @select('totalSel').val(sum).fixBid()
      @select('volumeSel').val(vol).fixAsk()

    [price, vol, sum]

  @getBalance = ->
    BigNumber( @select('currentBalanceSel').data('balance') )

  @getPrice = ->
    val = @select('priceSel').val() || '0'
    BigNumber(val)

  @getLastPrice = ->
    BigNumber(gon.ticker.last)

  @getVolume = ->
    val = @select('volumeSel').val() || '0'
    BigNumber(val)

  @getSum = ->
    val = @select('totalSel').val() || '0'
    BigNumber(val)

  @sanitize = (el) ->
    el.val '' if !$.isNumeric(el.val())

  @computeSum = (event) ->
    @sanitize @select('priceSel')
    @sanitize @select('volumeSel')

    return unless @getPrice().greaterThan(0)

    target = event.target
    if not @select('priceSel').is(target)
      @select('priceSel').fixBid()
    if not @select('volumeSel').is(target)
      @select('volumeSel').fixAsk()

    [price, volume, sum] = @solveEquation(@getPrice(), @getVolume(), null, @getBalance())

    @select('totalSel').val(sum).fixBid()

  @computeVolume = (event) ->
    @sanitize @select('priceSel')
    @sanitize @select('totalSel')

    return unless @getPrice().greaterThan(0)

    target = event.target
    if not @select('priceSel').is(target)
      @select('priceSel').fixBid()
    if not @select('totalSel').is(target)
      @select('totalSel').fixBid()

    [price, volume, sum] = @solveEquation(@getPrice(), null, @getSum(), @getBalance())

    @select('volumeSel').val(volume).fixAsk()

  @allIn = (event)->
    switch @panelType()
      when 'ask'
        @trigger 'place_order::input::price', {price: @getLastPrice()}
        @trigger 'place_order::input::volume', {volume: @getBalance()}
      when 'bid'
        @trigger 'place_order::input::price', {price: @getLastPrice()}
        @trigger 'place_order::input::total', {total: @getBalance()}

  @refreshBalance = (event, data) ->
    type = @panelType()
    currency = gon.market[type].currency
    balance = gon.accounts[currency].balance

    @select('currentBalanceSel').data('balance', balance)
    @trigger 'place_order::balance::change', balance: BigNumber(balance)

    switch type
      when 'bid'
        @select('currentBalanceSel').text(balance).fixBid()
        @trigger 'place_order::max::total', max: BigNumber(balance)
      when 'ask'
        @select('currentBalanceSel').text(balance).fixAsk()
        @trigger 'place_order::max::volume', max: BigNumber(balance)

  @updateAvailable = (event, order) ->
    type = @panelType()
    node = @select('currentBalanceSel')

    switch type
      when 'bid'
        available = window.fix 'bid', @getBalance().minus(order.total)
        if BigNumber(available).equals(0)
          @select('positionsLabelSel').hide().text(gon.i18n.place_order.full_in).fadeIn()
        else
          @select('positionsLabelSel').fadeOut().text('')
        node.text(available)
      when 'ask'
        available = window.fix 'ask', @getBalance().minus(order.volume)
        if BigNumber(available).equals(0)
          @select('positionsLabelSel').hide().text(gon.i18n.place_order.full_out).fadeIn()
        else
          @select('positionsLabelSel').fadeOut().text('')
        node.text(available)

  @priceAlertHide = (event) ->
    @select('priceAlertSel').fadeOut ->
      $(@).text('')

  @priceAlertShow = (event, data) ->
    @select('priceAlertSel')
      .hide().text(gon.i18n.place_order[data.label]).fadeIn()

  @after 'initialize', ->
    type = @panelType()

    PlaceOrderData.attachTo @$node
    OrderPriceUI.attachTo   @select('priceSel'),  form: @$node, type: type
    OrderVolumeUI.attachTo  @select('volumeSel'), form: @$node, type: type
    OrderTotalUI.attachTo   @select('totalSel'),  form: @$node, type: type

    @on 'place_order::price_alert::hide', @priceAlertHide
    @on 'place_order::price_alert::show', @priceAlertShow
    @on 'place_order::order::updated', @updateAvailable

    @on document, 'account::update', @refreshBalance

    @on @select('formSel'), 'ajax:beforeSend', @beforeSend
    @on @select('formSel'), 'ajax:success', @handleSuccess
    @on @select('formSel'), 'ajax:error', @handleError

    @on @select('currentBalanceSel'), 'click', @allIn
