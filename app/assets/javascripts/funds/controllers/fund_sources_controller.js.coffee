app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', ($scope, $gon, fundSourceService) ->

  $scope.currency = currency = $scope.ngDialogData.currency
  $scope.fund_sources = fund_sources = $gon.fund_sources
  $scope.banks = $gon.banks

  $scope.remove = (fs) ->
    fundSourceService.remove fs, ->
      fund_sources.splice fund_sources.indexOf(fs), 1

  $scope.add = ->
    currency = $scope.currency
    uid      = $scope.uid
    extra    = $scope.extra
    fundSourceService.add currency, uid, extra, (fs) ->
      $scope.uid = ""
      fund_sources.push fs

]
