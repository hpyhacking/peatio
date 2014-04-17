@FlashMessageUI = flight.component ->

  @defaultAttrs
    template: 'flash_message'

  @showMeg = (data) ->
    template = JST[@attr.template](data)
    $(template).prependTo(@$node)

  @info = (event, data) ->
    data.info = true
    @showMeg(data)

  @notice = (event, data) ->
    data.notice = true
    @showMeg(data)

  @alert = (event, data) ->
    data.alert = true
    @showMeg(data)

  @after 'initialize', ->
    @on document, 'flash-info', @info
    @on document, 'flash-notice', @notice
    @on document, 'flash-alert', @alert

