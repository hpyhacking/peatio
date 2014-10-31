app.controller 'DepositHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  @currency = $stateParams.currency
  @account = Account.findBy('currency', @currency)
  @deposits = @account.deposits()
  @newRecord = (deposit) ->
    if deposit.aasm_state == "submitting" then true else false

  @noDeposit = ->
    @deposits.length == 0

  @refresh = ->
    @deposits = @account.deposits()
    $scope.$apply()

  @cancelDeposit = (deposit) ->
    deposit_channel = DepositChannel.findBy('currency', deposit.currency)
    $http.delete("/deposits/#{deposit_channel.resources_name}/#{deposit.id}")
      .error (data) ->
        $.publish 'flash', { message: data.responseText }

  do @event = ->
    Deposit.bind "create update destroy", ->
      ctrl.refresh()
