app.controller 'DepositHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @deposits = @account.deposits().slice(0, 3)
  @newRecord = (deposit) ->
    if deposit.aasm_state == "submitting" then true else false

  @noDeposit = ->
    @deposits.length == 0

  @refresh = ->
    @deposits = @account.deposits().slice(0, 3)
    $scope.$apply()

  @cancelDeposit = (deposit) ->
    deposit_channel = DepositChannel.findBy('currency', deposit.currency)
    $http.delete("/deposits/#{deposit_channel.resource_name}/#{deposit.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  @canCancel = (state) ->
    ['submitting'].indexOf(state) > -1

  do @event = ->
    Deposit.bind "create update destroy", ->
      ctrl.refresh()
