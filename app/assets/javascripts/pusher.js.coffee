class PusherSubscriber
  constructor: ->
    pusher_key = $("meta[name=pusher]").attr("content")
    @socket = window.pusher
    @channels = []
    @subscribeChannels(current_user.sn)

  release: ->
    @socket.disconnect()
    @channels = []

  subscribeChannels: (user_sn) =>
    @subscribeUserChannel(user_sn)

  subscribeUserChannel: (user_sn)->
    channel = @socket.subscribe("private-" + user_sn)
    self = @
    channel.bind 'pusher:subscription_succeeded', (status) ->
      console.log('Pusher bind member channel successfully')
      new MemberHandler(channel)

class EventHandler
  constructor: (channel, event) ->
    @channel = channel
    @channel.bind event, @processWithoutAjax

  process: (msg) =>
    switch (msg.type)
      when "create"  then @create(msg.attributes)
      when "update"  then @update(msg.id, msg.attributes)
      when "destroy" then @destroy(msg.id, msg.attributes)
      else
        throw 'Unknown type:' + type

  processWithoutAjax: =>
    args = arguments
    PeatioModel.Ajax.disable =>
      @process(args...)

  create: (attributes) =>
  update: (id, attributes) =>
  destroy: (id) =>

class MemberHandler extends EventHandler
  constructor: (channel) ->
    super channel, "members"

  update: (id, attributes) =>
    Member.update(id, attributes)

window.PusherSubscriber = PusherSubscriber
