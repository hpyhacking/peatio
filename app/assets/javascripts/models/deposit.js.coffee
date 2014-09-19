attr = DS.attr

Peatio.Deposit = DS.Model.extend
  account_id: attr()
  member_id: attr()
  currency: attr()
  amount: attr()
  fee: attr()
  fund_uid: attr()
  fund_extra: attr()
  txid: attr()
  state: attr()
  aasm_state: attr()
  created_at: attr()
  updated_at: attr()
  done_at: attr()
  memo: attr()
  type: attr()

Peatio.Deposit.reopenClass
  initData: (data) ->
    window.store.createRecord('deposit', item) for item in data


