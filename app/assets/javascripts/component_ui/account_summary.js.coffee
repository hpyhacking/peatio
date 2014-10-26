@AccountSummaryUI = flight.component ->
  @attributes
    total_assets: '#total_assets'

  @updateAccount = (event, data) ->
    for currency, account of data
      amount = (new BigNumber(account.locked)).plus(new BigNumber(account.balance))
      @$node.find("tr.#{currency} span.amount").text(round(amount, 2))
      @$node.find("tr.#{currency} span.locked").text(round(account.locked, 2))

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

    @select('total_assets').text " #{symbol} #{round sum, 2}"

  @after 'initialize', ->
    @on document, 'account::update', @updateAccount
    @on document, 'account::update', @updateTotalAssets

