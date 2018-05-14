app.controller 'WithdrawsController', ['$scope', '$stateParams', '$http', '$gon', ($scope, $stateParams, $http, $gon) ->

  $scope.currency = currency = $stateParams.currency
  $scope.currencyTranslationLocals = currency: currency.toUpperCase()
  $scope.current_user = current_user = $gon.user
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance
  $scope.currencyType = if _.include(gon.fiat_currencies, $scope.currency) then 'fiat' else 'coin'

  @withdraw = {}
  @createWithdraw = (currency) ->
    data =
      withdraw:
        member_id: current_user.id
        currency:  currency
        sum:       @withdraw.sum
        rid:       @withdraw.rid

    $('.form-submit > input').attr('disabled', 'disabled')

    $http.post("/withdraws/#{currency}", data)
      .error (responseText) ->
        $.publish 'flash', { message: responseText }
      .finally =>
        @withdraw = {}
        $('.form-submit > input').removeAttr('disabled')
        $.publish 'withdraw:form:submitted'

  @withdrawAll = ->
    @withdraw.sum = '' + $scope.account.balance
]
