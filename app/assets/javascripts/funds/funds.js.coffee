#= require_tree ./models
#= require_self

$ ->
  window.pusher_subscriber = new PusherSubscriber()

Member.initData [window.current_user]
DepositChannel.initData window.deposit_channels
WithdrawChannel.initData window.withdraw_channels
Deposit.initData window.deposits
Account.initData window.accounts
Currency.initData window.currencies
Withdraw.initData window.withdraws
FundSource.initData window.fund_sources


angular.module('translateFilters', []).filter 't', ->
  (key) ->
    I18n.t(key)

window.app = app = angular.module 'funds', ["ui.router", "translateFilters"]

app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state('deposits', {
      url: '/deposits'
      templateUrl: "/templates/deposits.html"
    })
    .state('deposits.currency', {
      url: "/:currency"
      templateUrl: "/templates/deposit.html"
      controller: 'DepositsController'
    })

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

app.controller 'DepositsController', ($scope, $stateParams, $http) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.name = current_user.name
  $scope.fsources = FundSource.findAllBy('currency', $scope.currency)
  $scope.predicate = '-id'

  @createDeposit = (currency) ->
    depositCtrl = @
    deposit_channel = DepositChannel.findBy('currency', currency)
    account = deposit_channel.account()

    data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: @deposit.sum, fund_source: @deposit.fund_source }

    $('.form-submit > input').attr('disabled', 'disabled')

    $http.post("/deposits/#{deposit_channel.resources_name}", { deposit: data})
      .error (data) ->
        $.publish 'flash', {message: data.responseText }
      .finally ->
        depositCtrl.deposit = {}
        $('.form-submit > input').removeAttr('disabled')


app.controller 'DepositHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  @currency = $stateParams.currency
  @account = Account.findBy(currency: @currency)
  @deposits = @account.deposits()
  @newRecord = (deposit) ->
    if deposit.aasm_state == "submitting" then true else false

  @noDeposit = ->
    @deposits.length == 0

  @refresh = ->
    @deposits = @account.deposits()

  @cancelDeposit = (deposit) ->
    deposit_channel = DepositChannel.findBy('currency', deposit.currency)
    $http.delete("/deposits/#{deposit_channel.resources_name}/#{deposit.id}")
      .error (data) ->
        $.publish 'flash', {message: data.responseText }

  do @event = ->
    Deposit.bind "create update destroy", ->
      ctrl.refresh()
