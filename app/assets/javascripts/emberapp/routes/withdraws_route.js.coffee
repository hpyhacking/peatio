Peatio.WithdrawsRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('account').withdraw_channels()
