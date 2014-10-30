app.controller 'DepositsController', ($scope, $stateParams, $http) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.name = current_user.name
  $scope.fsources = FundSource.findAllBy('currency', $scope.currency)
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.deposit_channel = DepositChannel.findBy('currency', $scope.currency)

  @createDeposit = (currency) ->
    depositCtrl = @
    deposit_channel = DepositChannel.findBy('currency', currency)
    account = deposit_channel.account()

    data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: @deposit.amount, fund_source: @deposit.fund_source }

    $('.form-submit > input').attr('disabled', 'disabled')

    $http.post("/deposits/#{deposit_channel.resources_name}", { deposit: data})
      .error (data) ->
        $.publish 'flash', {message: data.responseText }
      .finally ->
        depositCtrl.deposit = {}
        $('.form-submit > input').removeAttr('disabled')

  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)


