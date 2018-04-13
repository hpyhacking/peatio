class Deposit extends PeatioModel.Model
  @configure 'Deposit', 'member_id', 'currency', 'amount', 'fee', 'address', 'txid', 'aasm_state', 'created_at', 'updated_at', 'completed_at', 'type', 'confirmations', 'transaction_url'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Deposit.create(record)

window.Deposit = Deposit



