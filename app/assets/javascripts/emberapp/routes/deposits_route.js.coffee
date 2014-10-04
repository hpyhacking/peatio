Peatio.DepositsRoute = Ember.Route.extend
  model: (params) ->
    account = @modelFor('account')
    window.current_account_action = "#{account.currency}:deposit"
    account.deposit_channels()
