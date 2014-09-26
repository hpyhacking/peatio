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
      new AccountHandler(channel)
      new DepositHandler(channel)
      new WithdrawHandler(channel)
      new PaymentAddressHandler(channel)

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

class AccountHandler extends EventHandler
  constructor: (channel) ->
    super channel, "accounts"

  update: (id, attributes) =>
    Account.update(id, attributes)


class DepositHandler extends EventHandler
  constructor: (channel) ->
    super channel, "deposits"

  create: (attributes) =>
    Deposit.create(attributes)

  update: (id, attributes) =>
    Deposit.update(id, attributes)

  destroy: (id) =>
    Deposit.destroy(id)

class WithdrawHandler extends EventHandler
  constructor: (channel) ->
    super channel, "withdraws"

  create: (attributes) =>
    Withdraw.create(attributes)
    $.publish('withdraw:create')

  update: (id, attributes) =>
    Withdraw.update(id, attributes)

  destroy: (id) =>
    Withdraw.destroy(id)

class PaymentAddressHandler extends EventHandler
  constructor: (channel) ->
    super channel, "payment_address"

  create: (attributes) =>
    account = Account.findBy('id', attributes['account_id'])
    account.payment_address = attributes['address']
    account.save()
    $.publish "payment_address:create"


window.PusherSubscriber = PusherSubscriber
