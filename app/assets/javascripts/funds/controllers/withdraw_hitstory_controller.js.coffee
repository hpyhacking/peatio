app.controller 'WithdrawHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @withdraws = @account.withdraws()
  @newRecord = (withdraw) -> withdraw.aasm_state is 'created'

  @noWithdraw = ->
    @withdraws.length == 0

  @refresh = ->
    ctrl.withdraws = ctrl.account.withdraws()
    $scope.$apply()

  @canCancel = (state) ->
    ['created', 'submitted', 'accepted'].indexOf(state) > -1

  @cancelWithdraw = (withdraw) ->
    $http.delete("/withdraws/#{$stateParams.currency}/#{withdraw.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  do @event = ->
    Withdraw.bind "create update destroy", ->
      ctrl.refresh()
