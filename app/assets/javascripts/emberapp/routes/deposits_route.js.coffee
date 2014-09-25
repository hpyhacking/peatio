Peatio.DepositsRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('account').deposit_channels()
