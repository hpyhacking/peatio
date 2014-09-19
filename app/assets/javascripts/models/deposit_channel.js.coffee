attr = DS.attr

Peatio.DepositChannel = DS.Model.extend
  key: attr()
  currency: attr()
  min_confirm: attr()
  max_confirm: attr()
  bank_accounts: attr()

Peatio.DepositChannel.reopenClass
  initData: (data) ->
    window.store.createRecord('deposit-channel', item.attributes) for item in data
