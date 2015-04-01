app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$gon', ($scope, $stateParams, $http, $gon) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.current_user = current_user = $gon.current_user
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

    $http.post("/deposits/#{deposit_channel.resource_name}", { deposit: data})
      .error (responseText) ->
        $.publish 'flash', {message: responseText }
      .finally ->
        depositCtrl.deposit = {}
        $('.form-submit > input').removeAttr('disabled')

  $scope.genAddress = (resource_name) ->
    $("a#new_address").html('...')
    $("a#new_address").attr('disabled', 'disabled')

    $http.post("/deposits/#{resource_name}/gen_address", {})
      .error (responseText) ->
        $.publish 'flash', {message: responseText }
      .finally ->
        $("a#new_address").html(I18n.t("funds.deposit_coin.new_address"))
        $("a#new_address").attr('disabled', 'disabled')



  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)

]
