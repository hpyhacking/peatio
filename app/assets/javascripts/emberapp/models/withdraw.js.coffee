class Withdraw extends PeatioModel.Model
  @configure 'Withdraw', 'sn', 'acount_id', 'member_id', 'currency', 'amount', 'fee', 'fund_uid', 'fund_extra',
    'created_at', 'updated_at', 'done_at', 'txid', 'aasm_state', 'sum', 'type'

  @extend PeatioModel.Model.Ajax

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Withdraw.create(record)

  afterScope: ->
    "#{@pathName()}"

  pathName: ->
    switch @currency
      when 'cny' then 'banks'
      when 'btc' then 'satoshis'

window.Withdraw = Withdraw
