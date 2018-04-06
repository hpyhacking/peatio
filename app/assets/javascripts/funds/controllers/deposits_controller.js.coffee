app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', ($scope, $stateParams, $http, $filter, $gon) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.currencyTranslationLocals = currency: $stateParams.currency.toUpperCase()
  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.deposit_channel = DepositChannel.findBy('currency', $scope.currency)
  $scope.fiatCurrency = gon.fiat_currency
  $scope.fiatCurrencyTranslationLocals = currency: gon.fiat_currency.toUpperCase()

  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)

]
