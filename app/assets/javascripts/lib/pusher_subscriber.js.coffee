class PusherSubscriber
  constructor: ->
    pusher_key = $("meta[name=pusher]").attr("content")
    @socket = window.pusher
    @channels = []
    @subscribeChannels(gon.user.sn)

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
      new AccountHandler(channel)
      new DepositHandler(channel)
      new WithdrawHandler(channel)
      new DepositAddressHandler(channel)

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

class AccountHandler extends EventHandler
  constructor: (channel) ->
    super channel, "accounts"

  update: (id, attributes) =>
    account = Account.findBy("id", id).updateAttributes(attributes)


class DepositHandler extends EventHandler
  constructor: (channel) ->
    super channel, "deposits"

  create: (attributes) =>
    Deposit.create(attributes)
    $.publish 'deposit:create'

  update: (id, attributes) =>
    Deposit.findBy("id", id).updateAttributes(attributes)

class WithdrawHandler extends EventHandler
  constructor: (channel) ->
    super channel, "withdraws"

  create: (attributes) =>
    Withdraw.create(attributes)

  update: (id, attributes) =>
    Withdraw.findBy("id", id).updateAttributes(attributes)

  destroy: (id) =>
    Withdraw.destroy(id)

class DepositAddressHandler extends EventHandler
  constructor: (channel) ->
    super channel, "deposit_address"

  create: (attributes) =>
    account = Account.findBy('id', attributes['account_id'])
    account.deposit_address = attributes['deposit_address']
    account.save()
    $.publish "deposit_address:create", attributes['deposit_address']


window.PusherSubscriber = PusherSubscriber
