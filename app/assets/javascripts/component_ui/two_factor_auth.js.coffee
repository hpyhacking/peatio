@TwoFactorAuth = flight.component ->
  @defaultAttrs
    switchName: 'span.switch-name'
    switchItem: '.dropdown-menu a'
    sendCodeButton: '.send-code-button'

  @setActiveItem = (event) ->
    item = $(event.target)
    @select('switchName').text item.text()

    type = item.data('type')
    switch type
      when 'app' then @switchToApp()
      when 'sms' then @switchToSms()

  @switchToApp = ->
    @select('sendCodeButton').addClass('hide')

  @switchToSms = ->
    @select('sendCodeButton').removeClass('hide')

  @after 'initialize', ->
    @on @select('switchItem'), 'click', @setActiveItem
