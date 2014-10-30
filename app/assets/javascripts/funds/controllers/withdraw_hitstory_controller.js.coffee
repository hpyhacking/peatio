app.controller 'WithdrawHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @withdraws = @account.withdraws()
  @newRecord = (withdraw) ->
    if withdraw.aasm_state ==  "submitting" then true else false

  @noWithdraw = ->
    @withdraws.length == 0

  do @event = ->
    Withdraw.bind "create update destroy", ->
      ctrl.withdraws = ctrl.account.withdraws()
      $scope.$apply()
