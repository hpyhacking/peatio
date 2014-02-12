window.TradeHistoryCancelUI = flight.component ->
  @.after 'initialize', ->
    @.on document, 'order::cancel', (event, data) =>
      data.callback = =>
        @.trigger 'fixed', 5
      @.trigger 'replaceOrNew', data
