class Withdraw extends PeatioModel.Model
  @configure 'Withdraw', 'sn', 'acount_id', 'member_id', 'currency', 'amount', 'fee', 'fund_uid', 'fund_extra',
    'created_at', 'updated_at', 'done_at', 'txid', 'aasm_state', 'sum', 'type'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Withdraw.create(record)


window.Withdraw = Withdraw
