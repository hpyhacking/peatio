app.directive 'accounts', ->
  return {
    restrict: 'E'
    templateUrl: '/templates/accounts.html'
    scope: { localValue: '=accounts' }
    controller: ($scope, $state) ->
      ctrl = @
      @state = $state
      @state.transitionTo("deposits.currency", {currency: Account.first().currency}) if window.location.hash == ""
      $scope.accounts = Account.all()

      # Might have a better way
      # #/deposits/cny
      @selectedCurrency = window.location.hash.split('/')[2]
      @currentAction = window.location.hash.split('/')[1]

      @isSelected = (currency) ->
        @selectedCurrency == currency

      @isDeposit = ->
        @currentAction == 'deposits'

      @isWithdraw = ->
        @currentAction == 'withdraws'

      @deposit = (account) ->
        ctrl.state.transitionTo("deposits.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction = "deposits"

      @withdraw = (account) ->
        ctrl.state.transitionTo("withdraws.currency", {currency: account.currency})
        ctrl.selectedCurrency = account.currency
        ctrl.currentAction = "withdraws"

      do @event = ->
        Account.bind "create update destroy", ->
          $scope.$apply()

    controllerAs: 'accountsCtrl'
  }

