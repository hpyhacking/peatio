@MemberData = flight.component ->
  @after 'initialize', ->
    channel = @attr.pusher.subscribe("private-#{gon.current_user.sn}")

    channel.bind 'account', (data) =>
      ask_or_bid = gon.accounts[data.currency]
      gon.accounts[ask_or_bid] = data
      @trigger 'trade::account', gon.accounts

    channel.bind 'order', (data) =>
      @trigger "order::#{data.state}", data

    channel.bind 'trade', (data) =>
      @trigger 'trade::done', data

    # Initializing at bootstrap
    @trigger 'trade::account', gon.accounts

