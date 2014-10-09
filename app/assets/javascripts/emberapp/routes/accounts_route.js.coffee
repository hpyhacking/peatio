Peatio.AccountsRoute = Ember.Route.extend
  model: ->
    # sort accounts by the order of currencies
    (Account.findBy('currency', i.code) for i in Currency.all())
