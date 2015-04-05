app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', 'ngDialog', ($scope, $stateParams, $http, $filter, $gon, ngDialog) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.current_user = current_user = $gon.current_user
  $scope.name = current_user.name
  $scope.fund_sources = $gon.fund_sources
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

  $scope.openFundSourceManagerPanel = ->
    ngDialog.open
      template: '/templates/fund_sources/bank.html'
      controller: 'FundSourcesController'
      className: 'ngdialog-theme-default custom-width'
      data: {currency: $scope.currency}

  $scope.genAddress = (resource_name) ->
    ngDialog.openConfirm
      template: '/templates/shared/confirm_dialog.html'
      data: {content: $filter('t')('funds.deposit_coin.confirm_gen_new_address')}
    .then ->
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
