app.controller 'DepositsController', ['$scope', '$stateParams', '$http', '$filter', '$gon', ($scope, $stateParams, $http, $filter, $gon) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.currencyTranslationLocals = currency: $stateParams.currency.toUpperCase()
  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.currencyType = if _.include(gon.fiat_currencies, $scope.currency) then 'fiat' else 'coin'

  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      $.publish 'deposit_address:create'
    , 1000)

]
