class Deposit extends PeatioModel.Model
  @configure 'Deposit', 'account_id', 'member_id', 'currency', 'amount', 'fee',
    'txid', 'state', 'aasm_state', 'created_at', 'updated_at', 'done_at', 'type', 'confirmations', 'transaction_url', 'txid_desc'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Deposit.create(record)

window.Deposit = Deposit



