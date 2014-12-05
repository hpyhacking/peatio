@SmsAuthVerifyUI = flight.component ->

  @countDown = 0

  @attributes
    phoneNumberInput: '#token_sms_token_phone_number'
    verifyCodeInput: '#token_sms_token_verify_code'
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
    @countDown = 30

    @select('sendCodeButton').attr('disabled', 'disabled').addClass('disabled')
    countDownTimer = =>
      setTimeout =>
        if @countDown isnt 0
          @countDown--
          @select('sendCodeButton').text(altName.replace('COUNT', @countDown))
          countDownTimer()
        else
          @select('sendCodeButton').removeAttr('disabled').removeClass('disabled').text(origName)
      , 1000
    countDownTimer()

  @beforeSend = (event, jqXHR, settings) ->
    return if settings.data.match 'send_code'

    input = @select('verifyCodeInput')
    input.parent().removeClass 'has-error'
    if input.val() is ""
      input.parent().addClass 'has-error'
      jqXHR.abort()

  @handleSuccess = (event, text, status, jqXHR) ->
    data = JSON.parse(text)
    if data.reload
      window.location.reload()
    @trigger 'flash:notice', msg: data.text

  @handleError = (event, jqXHR, status, error) ->
    data = JSON.parse(jqXHR.responseText)
    @countDown = 0
    @trigger 'flash:alert', msg: data.text

  @after 'initialize', ->
    @on @select('sendCodeButton'), 'click', @verifyPhoneNumber
    @on 'ajax:beforeSend', @beforeSend
    @on 'ajax:success', @handleSuccess
    @on 'ajax:error', @handleError

