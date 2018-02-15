app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', 'ngDialog', ($scope, $stateParams, $http, $filter, $gon, ngDialog) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.fund_sources = $gon.fund_sources
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.deposit_channel = DepositChannel.findBy('currency', $scope.currency)
  $scope.fiatCurrency = gon.fiat_currency
  $scope.fiatCurrencyTranslationLocals = currency: gon.fiat_currency

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

      $http.post("/deposits/#{resource_name}/gen_address")
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
