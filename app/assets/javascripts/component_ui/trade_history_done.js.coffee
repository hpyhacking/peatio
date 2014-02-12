window.TradeHistoryDoneUI = flight.component ->
  @.after 'initialize', ->
    @.on document, 'order::done', (event, data) =>
      data.callback = =>
        @.trigger 'fixed', 5
      @.trigger 'replaceOrNew', data
