@TwoFactorAuth = flight.component ->
  @defaultAttrs
    switchName: 'span.switch-name'
    switchItem: '.dropdown-menu a'
    switchItemApp: '.dropdown-menu a[data-type="app"]'
    switchItemSms: '.dropdown-menu a[data-type="sms"]'
    sendCodeButtonContainer: '.send-code-button'
    sendCodeButton: 'button[value=send_code]'
    authType: '.two_factor_auth_type'
    appHint: 'span.hint.app'
    smsHint: 'span.hint.sms'

  @setActiveItem = (event) ->
    switch $(event.target).data('type')
      when 'app' then @switchToApp()
      when 'sms' then @switchToSms()

  @switchToApp = ->
    @select('switchName').text @select('switchItemApp').text()
    @select('sendCodeButtonContainer').addClass('hide')
    @select('authType').val('app')
    @select('smsHint').addClass('hide')
    @select('appHint').removeClass('hide')
    @rememberLastSelecct('app')

  @switchToSms = ->
    @select('switchName').text @select('switchItemSms').text()
    @select('sendCodeButtonContainer').removeClass('hide')
    @select('authType').val('sms')
    @select('smsHint').removeClass('hide')
    @select('appHint').addClass('hide')
    @rememberLastSelecct('sms')

  @countDownSendCodeButton = ->
    origName  = @select('sendCodeButton').data('orig-name')
    altName   = @select('sendCodeButton').data('alt-name')
    countDown = 30

    @select('sendCodeButton').attr('disabled', 'disabled').addClass('disabled')
    countDownTimer = =>
      setTimeout =>
        if countDown isnt 0
          countDown--
          @select('sendCodeButton').text(altName.replace('COUNT', countDown))
          countDownTimer()
        else
          @select('sendCodeButton').removeAttr('disabled').removeClass('disabled').text(origName)
      , 1000
    countDownTimer()

  @sendCode = ->
    @countDownSendCodeButton()
    $.get('/refresh_two_factors/sms')

  @rememberLastSelecct = (type) ->
    if localStorage
      localStorage["two_factor_auth_type"] = ['app', 'sms'].indexOf(type)

  @resumeLastSelect = (type) ->
    if localStorage
      index = parseInt(localStorage["two_factor_auth_type"] || '0')
      switch index
        when 0 then @switchToApp()
        when 1 then @switchToSms()

  @after 'initialize', ->
    @on @select('switchItem'), 'click', @setActiveItem
    @on @select('sendCodeButton'), 'click', @sendCode
    @resumeLastSelect()

