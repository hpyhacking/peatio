@TwoFactorAuth = flight.component ->
  @defaultAttrs
    buttonName: '.input-group-btn button span.name'
    sendCodeButton: '.send-code-button'
    two_factor: '.dropdown-menu a'

  @setActiveItem = (event) ->
    item = $(event.target)
    @select('buttonName').text item.text()

    type = item.data('type')
    switch type
      when 'app' then @switchToApp()
      when 'sms' then @switchToSms()

  @switchToApp = ->
    @select('sendCodeButton').addClass('hide')

  @switchToSms = ->
    @select('sendCodeButton').removeClass('hide')

  @after 'initialize', ->
    @on @select('two_factor'), 'click', @setActiveItem
