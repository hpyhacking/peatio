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

class AccountHandler extends EventHandler
  constructor: (channel) ->
    super channel, "accounts"

  update: (id, attributes) =>
    account = Account.findBy("id", id).updateAttributes(attributes)
    for k,v of attributes
       account.set(k, 'To The Moon') # This line is neccessay due some weird bug.
       account.set(k, v)
    $.publish 'account:update', {id: id, attributes: attributes}


class DepositHandler extends EventHandler
  constructor: (channel) ->
    super channel, "deposits"

  create: (attributes) =>
    Deposit.create(attributes)
    $.publish 'deposit:create'

  update: (id, attributes) =>
    deposit = Deposit.findBy("id", id).updateAttributes(attributes)
    for k,v of attributes
       deposit.set(k, 'To The Moon') # This line is neccessay due some weird bug.
       deposit.set(k, v)
    $.publish 'deposit:update', {id: id, attributes: attributes}

class WithdrawHandler extends EventHandler
  constructor: (channel) ->
    super channel, "withdraws"

  create: (attributes) =>
    Withdraw.create(attributes)
    $.publish('withdraw:create')

  update: (id, attributes) =>
    withdraw = Withdraw.findBy("id", id).updateAttributes(attributes)
    for k,v of attributes
       withdraw.set(k, 'To The Moon') # This line is neccessay due some weird bug.
       withdraw.set(k, v)
    $.publish 'withdraw:update', {id: id, attributes: attributes}

  destroy: (id) =>
    Withdraw.destroy(id)

class PaymentAddressHandler extends EventHandler
  constructor: (channel) ->
    super channel, "payment_address"

  create: (attributes) =>
    account = Account.findBy('id', attributes['account_id'])
    account.payment_address = attributes['address']
    account.set('payment_address', 'To The Moon')
    account.set('payment_address', attributes['address'])
    account.save()
    $.publish "payment_address:create"


window.PusherSubscriber = PusherSubscriber
