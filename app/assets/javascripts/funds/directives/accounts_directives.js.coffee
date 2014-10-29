app.directive 'accounts', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/accounts.html'
    scope: { localValue: '=accounts' }
    controller: ($scope) ->
      ctrl = @
      $scope.accounts = Account.all()
      @selectedCurrency = $scope.accounts[0].currency
      @currentAction = 'deposit'

      @isSelected = (currency) ->
        @selectedCurrency == currency

      @isDeposit = ->
        @currentAction == 'deposit'

      @isWithdraw = ->
        @currentAction == 'withdraw'

      do @event = ->
        Account.bind "create update destroy", ->
          $scope.$apply()

    controllerAs: 'accountsCtrl'
  }

