@AccountData = flight.component ->
  @after 'initialize', ->
    @attr.channel = @attr.pusher.subscribe("private-#{gon.current_user.sn}")
    @attr.channel.bind 'account', (data) =>
      ask_or_bid = gon.accounts[data.currency]
      gon.accounts[ask_or_bid] = data
      @trigger 'trade::account', gon.accounts

    # Initializing at bootstrap
    @trigger 'trade::account', gon.accounts

