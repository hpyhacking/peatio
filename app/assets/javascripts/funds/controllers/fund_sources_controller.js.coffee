app.controller 'FundSourcesController', ['$scope', 'fundSourceService', ($scope, fundSourceService) ->

  $scope.currency = $scope.ngDialogData.currency
  $scope.fund_sources = fundSourceService.filterByCurrency($scope.currency)

]
