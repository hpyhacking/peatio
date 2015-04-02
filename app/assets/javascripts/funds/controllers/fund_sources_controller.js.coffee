app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', ($scope, $gon, fundSourceService) ->

  $scope.currency = $scope.ngDialogData.currency
  $scope.fund_sources = fundSourceService.filterByCurrency($scope.currency)
  $scope.banks = $gon.banks
  $scope.uid = ""

  $scope.remove = (fund_source) ->
    console.info fund_source

  $scope.add = ->
    uid = $scope.uid.trim()
    return if uid == ""

    console.info $scope.extra, $scope.uid

]
