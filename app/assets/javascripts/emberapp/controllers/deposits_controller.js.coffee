Peatio.DepositsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()
    Peatio.set('deposits-controller', @)
    $.subscribe('deposit:create', ->
      controller.get('deposits').setObjects(controller.get('model')[0].account().topDeposits())
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

  deposits: (->
    @model[0].account().topDeposits()
  ).property('@each')
