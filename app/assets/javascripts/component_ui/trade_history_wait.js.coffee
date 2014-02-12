window.TradeHistoryWaitUI = flight.component ->
  @.after 'initialize', ->
    @.on document, 'order::wait', (event, data) =>
      @.trigger 'replaceOrNew', data

    @.on document, 'order::cancel', (event, data) =>
      @.trigger 'move', data

    @.on document, 'order::done', (event, data) =>
      @.trigger 'move', data
