window.OrderData = flight.component ->
  @after 'initialize', ->
    @attr.channel = @attr.pusher.subscribe("private-#{gon.current_user.sn}")
    @attr.channel.bind 'order', (data) =>
      @trigger "order::#{data.state}", data
