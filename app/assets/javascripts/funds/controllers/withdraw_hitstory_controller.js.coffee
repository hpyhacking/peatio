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

  do @event = ->
    Withdraw.bind "create update destroy", ->
      ctrl.refresh()
