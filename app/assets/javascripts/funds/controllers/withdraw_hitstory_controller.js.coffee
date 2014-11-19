app.controller 'WithdrawHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @withdraws = @account.withdraws().slice(0, 3)
  @newRecord = (withdraw) ->
    if withdraw.aasm_state ==  "submitting" then true else false

  @noWithdraw = ->
    @withdraws.length == 0

  @refresh = ->
    ctrl.withdraws = ctrl.account.withdraws().slice(0, 3)
    $scope.$apply()

  @canCancel = (state) ->
    ['submitting', 'submitted', 'accepted'].indexOf(state) > -1

  @cancelWithdraw = (withdraw) ->
    withdraw_channel = WithdrawChannel.findBy('currency', withdraw.currency)
    $http.delete("/withdraws/#{withdraw_channel.resource_name}/#{withdraw.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  do @event = ->
    Withdraw.bind "create update destroy", ->
      ctrl.refresh()
