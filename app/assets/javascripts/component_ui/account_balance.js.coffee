@AccountBalanceUI = flight.component ->
  @updateAccount = (event, data) ->
    for currency, account of data
      symbol = gon.currencies[currency].symbol || ''
      @$node.find(".account.#{currency} span.balance").text "#{account.balance}"
      @$node.find(".account.#{currency} span.locked").text "#{account.locked}"
      total = (new BigNumber(account.locked)).plus(new BigNumber(account.balance))
      @$node.find(".account.#{currency} span.total").text "#{symbol}#{formatter.round total, 2}"

  @updateTotalAssets = (event, data) ->
    fiatCurrency = gon.fiat_currency
    symbol = gon.currencies[fiatCurrency].symbol
    sum = 0
    for currency, account of data
      if currency is fiatCurrency
        sum += +account.balance
        sum += +account.locked
      else if ticker = gon.tickers["#{currency}#{fiatCurrency}"]
        sum += +account.balance * +ticker.last
        sum += +account.locked * +ticker.last

    @$node.find(".total-assets").text " ≈ #{symbol} #{formatter.round sum, 2}"

  @after 'initialize', ->
    @on document, 'account::update', @updateAccount
    @on document, 'account::update', @updateTotalAssets

