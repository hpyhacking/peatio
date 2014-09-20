class PusherSubscriber
  constructor: ->
    pusher_key = $("meta[name=pusher]").attr("content")
    @socket = new Pusher(pusher_key)
    @socket.connection.bind 'connected', @pusherConnected
    @socket.connection.bind 'unavailable', @pusherUnavailable
    @channels = []
    @subscribeChannels(current_user.id)

  release: ->
    @socket.disconnect()
    @channels = []

  pusherConnected: =>
    $.ajaxPrefilter (options, originalOptions, xhr) =>
      xhr.setRequestHeader('X-WebSocket-ID', @socket.connection.socket_id)
    $.publish "flash:close"

  pusherUnavailable: =>
    $.publish "flash:warn", '请刷新'

  subscribeChannels: (user_sn) =>
    @subscribeUserChannel(user_sn)

  subscribeUserChannel: ->


