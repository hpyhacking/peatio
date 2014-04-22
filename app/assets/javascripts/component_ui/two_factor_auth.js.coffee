@TwoFactorAuth = flight.component ->
  @defaultAttrs
    switchName: 'span.switch-name'
    switchItem: '.dropdown-menu a'
    sendCodeButton: '.send-code-button'
    authType: '.two_factor_auth_type'
    appHint: 'span.hint.app'
    smsHint: 'span.hint.sms'

  @setActiveItem = (event) ->
    item = $(event.target)
    @select('switchName').text item.text()

    type = item.data('type')
    switch type
      when 'app' then @switchToApp()
      when 'sms' then @switchToSms()

  @switchToApp = ->
    @select('sendCodeButton').addClass('hide')
    @select('authType').val('app')
    @select('smsHint').addClass('hide')
    @select('appHint').removeClass('hide')

  @switchToSms = ->
    @select('sendCodeButton').removeClass('hide')
    @select('authType').val('sms')
    @select('smsHint').removeClass('hide')
    @select('appHint').addClass('hide')

  @after 'initialize', ->
    @on @select('switchItem'), 'click', @setActiveItem
