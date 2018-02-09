class Withdraw extends PeatioModel.Model
  @configure 'Withdraw', 'sn', 'account_id', 'member_id', 'currency', 'amount', 'fee', 'fund_uid', 'fund_extra',
    'created_at', 'updated_at', 'done_at', 'txid', 'blockchain_url', 'aasm_state', 'sum', 'type', 'is_submitting'

  constructor: ->
    super
    @is_submitting = @aasm_state == "submitting"

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Withdraw.create(record)

  afterScope: ->
    "#{@pathName()}"

  pathName: ->
    switch @currency.toUpperCase()
      when gon.fiat_currency then 'banks'
      when 'BTC'  then 'satoshis'
      when 'XRP'  then 'ripples'
      when 'LTC'  then 'litoshis'
      when 'BCH'  then 'bitcoin_cash'
      when 'DASH' then 'duffs'

window.Withdraw = Withdraw
