attr = DS.attr

Peatio.Currency = DS.Model.extend
  key: attr()
  code: attr()
  coin: attr()
  key: attr()
  blockchain: attr()

Peatio.Currency.reopenClass
  initData: (data) ->
    window.store.createRecord('currency', item.attributes) for item in data
