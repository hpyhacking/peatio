app.controller 'DepositHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @deposits = @account.deposits()
  @newRecord = (deposit) ->
    deposit.aasm_state is 'submitted'

  @noDeposit = ->
    @deposits.length == 0

  @refresh = ->
    @deposits = @account.deposits()
    $scope.$apply()

  @cancelDeposit = (deposit) ->
    $http.delete("/deposits/#{$stateParams.currency}/#{deposit.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  @canCancel = (state) ->
    ['submitted'].indexOf(state) > -1

  do @event = ->
    Deposit.bind "create update destroy", ->
      ctrl.refresh()
