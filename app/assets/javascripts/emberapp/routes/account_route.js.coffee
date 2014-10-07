Peatio.AccountRoute = Ember.Route.extend
  model: (params) ->
    Account.findBy 'currency', params.currency
