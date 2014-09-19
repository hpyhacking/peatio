attr = DS.attr

Peatio.Account = DS.Model.extend
  member_id: attr()
  currency: attr()
  balance: attr()
  locked: attr()
  created_at: attr()
  updated_at: attr()
  in: attr()
  out: attr()

Peatio.Account.reopenClass
  initData: (data) ->
    window.store.createRecord('account', item) for item in data
