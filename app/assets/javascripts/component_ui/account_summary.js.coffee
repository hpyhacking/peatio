@AccountSummaryUI = flight.component ->
  @attributes
    total_assets: '#total_assets'

  @updateAccount = (event, data) ->
    for currency, account of data
      amount = (new BigNumber(account.locked)).plus(new BigNumber(account.balance))
      @$node.find("tr.#{currency} span.amount").text(formatter.round(amount, 2))
      @$node.find("tr.#{currency} span.locked").text(formatter.round(account.locked, 2))

  @updateTotalAssets = ->
    fiatCurrency = gon.fiat_currency
    symbol = gon.currencies[fiatCurrency].symbol
    sum = 0

    for currency, account of @accounts
      if currency is fiatCurrency
        sum += +account.balance
        sum += +account.locked
      else if ticker = @tickers["#{currency}#{fiatCurrency}"]
        sum += +account.balance * +ticker.last
        sum += +account.locked * +ticker.last

    @select('total_assets').text "#{symbol}#{formatter.round sum, 2}"

  @after 'initialize', ->
    @accounts = gon.accounts
    @tickers  = gon.tickers

    @on document, 'account::update', @updateAccount

    @on document, 'account::update', (event, data) =>
      @accounts = data
      @updateTotalAssets()

    @on document, 'market::tickers', (event, data) =>
      @tickers = data.raw
      @updateTotalAssets()


