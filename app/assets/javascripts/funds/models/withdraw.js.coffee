class Withdraw extends PeatioModel.Model
  @configure 'Withdraw', 'account_id', 'member_id', 'currency', 'amount', 'fee', 'rid',
    'created_at', 'updated_at', 'completed_at', 'txid', 'wallet_url', 'transaction_url', 'aasm_state', 'sum', 'type'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Withdraw.create(record)

  afterScope: ->
    "#{@pathName()}"

  pathName: -> @currency

window.Withdraw = Withdraw
