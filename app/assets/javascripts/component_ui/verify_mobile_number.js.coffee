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
