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
      currentAction: 'deposit'
    })
    .state('withdraws', {
      url: '/withdraws'
      templateUrl: "/templates/withdraws.html"
    })
    .state('withdraws.currency', {
      url: "/:currency"
      templateUrl: "/templates/withdraw.html"
      currentAction: "withdraw"
    })
