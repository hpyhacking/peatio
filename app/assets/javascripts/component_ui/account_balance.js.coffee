@AccountBalanceUI = flight.component ->
  @updateAccount = (event, data) ->
    for currency, account of data
      symbol = gon.currencies[currency].symbol
      @$node.find(".account.#{currency} span.balance").text "#{account.balance} #{symbol}"
      @$node.find(".account.#{currency} span.locked").text "#{account.locked} #{symbol}"

  @after 'initialize', ->
    @on document, 'account::update', @updateAccount

