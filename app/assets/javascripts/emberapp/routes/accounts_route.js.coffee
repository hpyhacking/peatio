Peatio.AccountsRoute = Ember.Route.extend
  model: ->
    Account.all()
