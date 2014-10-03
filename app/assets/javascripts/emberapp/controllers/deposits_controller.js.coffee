Peatio.DepositsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()
    Peatio.set('deposits-controller', @)
    $.subscribe('deposit:create', ->
      controller.get('deposits').insertAt(0, controller.get('model')[0].account().deposits().pop())
      if controller.get('deposits') > 3
        setTimeout(->
          controller.get('deposits').popObject()
        , 1000)
    )

    $.subscribe('payment_address:create', ->
      $("#payment_address").html(controller.get('model')[0].account().payment_address)
    )

  paymentAddress: (->
    @model[0].account().payment_address
  ).property('@each')

  btc: (->
    @model[0].currency == "btc"
  ).property('@each')

  cny: (->
    @model[0].currency == "cny"
  ).property('@each')

  btsx: (->
    @model[0].currency == "btsx"
  ).property('@each')

  pts: (->
    @model[0].currency == "pts"
  ).property('@each')

  dog: (->
    @model[0].currency == "dog"
  ).property('@each')

  deposits: (->
    @model[0].account().topDeposits()
  ).property('@each')

  fsources: (->
    FundSource.findAllBy('currency', @model[0].currency)
  ).property('@each')

  name: (->
    current_user.name
  ).property()


  actions: {
    submitCnyDeposit: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#deposit_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: sum,  fund_source: fund_source }
      $('#deposit_cny_submit').attr('disabled', 'disabled')
      $.ajax({
        url: '/deposits/banks',
        method: 'post',
        data: { deposit: data }
      }).done(->
        $('#deposit_cny_submit').removeAttr('disabled')
      )

  }
