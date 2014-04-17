@VerifyMobileNumberUI = flight.component ->

  @defaultAttrs
    phoneNumberInput: '#sms_token_phone_number'
    verifyCodeInput: '#sms_token_verify_code'
    sendCodeButton: 'button[value=send_code]'

  @verifyPhoneNumber = (event, data) ->
    @select('phoneNumberInput').parent().removeClass 'has-error'

    if @select('phoneNumberInput').val() is ""
      @select('phoneNumberInput').parent().addClass 'has-error'
      event.preventDefault()
    else
      setTimeout =>
        @countDownSendCodeButton()
      , 0

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

  @beforeSend = (event, jqXHR) ->

  @handleSuccess = (event, text) ->
    App.showInfo text

  @handleError = (event, jqXHR) ->
    App.showAlert jqXHR.responseText

  @after 'initialize', ->
    @on @select('sendCodeButton'), 'click', @verifyPhoneNumber
    @on 'ajax:beforeSend', @beforeSend
    @on 'ajax:success', @handleSuccess
    @on 'ajax:error', @handleError
