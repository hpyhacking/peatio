Peatio.WithdrawsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()
    Peatio.set('withdraws-controller', @)
    $.subscribe('withdraw:create', ->
      controller.get('withdraws').insertAt(0, controller.get('model')[0].account().withdraws().pop())
      if controller.get('withdraws').length > 3
        setTimeout(->
          controller.get('withdraws').popObject()
        , 1000)
    )

  btc: (->
    @model[0].currency == "btc"
  ).property('@each')

  cny: (->
    @model[0].currency == "cny"
  ).property('@each')

  btsx: (->
    @model[0].currency == "btsx"
  ).property('@each')



  withdraws: (->
    @model[0].account().topWithdraws()
  ).property('@each')

  balance: (->
    @model[0].account().balance
  ).property('@each')

  fsources: (->
    FundSource.findAllBy('currency', @model[0].currency)
  ).property('@each')

  name: (->
    current_user.name
  ).property('')

  actions: {
    submitBtcWithdraw: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#withdraw_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { account_id: account.id, member_id: current_user.id, currency: currency, sum: sum,  fund_source: fund_source }
      $('#withdraw_btc_submit').attr('disabled', 'disabled')
      $.ajax({
        url: '/withdraws/satoshis',
        method: 'post',
        data: { withdraw: data}
      }).done(->
        $('#withdraw_btc_submit').removeAttr('disabled')
      )

    withdrawAll: ->
      $('#withdraw_sum').val(@get('balance'))

    submitCnyWithdraw: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#withdraw_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { account_id: account.id, member_id: current_user.id, currency: currency, sum: sum,  fund_source: fund_source }
      $('#withdraw_btc_submit').attr('disabled', 'disabled')
      $.ajax({
        url: '/withdraws/banks',
        method: 'post',
        data: { withdraw: data}
      }).done(->
        $('#withdraw_cny_submit').removeAttr('disabled')
      )
  }
