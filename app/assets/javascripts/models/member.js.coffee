attr = DS.attr

Peatio.Member = DS.Model.extend
  sn: attr()
  display_name: attr()
  email: attr()
  created_at: attr()
  updated_at: attr()
  state: attr()
  country_code: attr()
  phone_number: attr()

Peatio.Member.reopenClass
  initData: (data) ->
    window.store.createRecord('member', data)
