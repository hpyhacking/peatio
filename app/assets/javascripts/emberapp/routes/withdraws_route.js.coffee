Peatio.WithdrawsRoute = Ember.Route.extend
  model: (params) ->
    account = @modelFor('account')
    window.current_account_action = "#{account.currency}:withdraw"
    account.withdraw_channels()
