@SignUpUI = flight.component ->
  @defaultAttrs
    agree: '#agree'
    submitButton: ':submit'

  @toggleSubmit = (event, data) ->
    if @select('agree').is(':checked')
      @select('submitButton').removeClass('disabled').removeAttr('disabled')
    else
      @select('submitButton').addClass('disabled').attr('disabled', 'disabled')

  @after 'initialize', ->
    @on @select('agree'), 'change', @toggleSubmit

