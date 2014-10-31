class DepositChannel extends PeatioModel.Model
  @configure 'DepositChannel', 'key', 'currency', 'min_confirm', 'max_confirm', 'bank_accounts', 'resources_name'

  constructor: ->
    super
    switch @key
      when "satoshi" then @resources_name = 'satoshis'
      when "protoshare" then @resources_name = "protoshares"
      when "bank" then @resources_name = "banks"
      when "bitsharesx" then @resources_name = "bitsharesxes"
      when "dogecoin" then @resources_name = 'dogecoins'
      when "keyid" then @resources_name = 'keyids'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        DepositChannel.create(record.attributes)

  account: ->
    Account.findBy('currency', @currency)

window.DepositChannel = DepositChannel

