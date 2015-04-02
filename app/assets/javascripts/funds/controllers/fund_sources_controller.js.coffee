app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', ($scope, $gon, fundSourceService) ->

  $scope.currency = currency = $scope.ngDialogData.currency
  $scope.fund_sources = fund_sources = $gon.fund_sources
  $scope.banks = $gon.banks

  $scope.remove = (fs) ->
    fundSourceService.remove fs, ->
      fund_sources.splice fund_sources.indexOf(fs), 1

  $scope.add = ->
    uid   = $scope.uid.trim()   if angular.isString($scope.uid)
    extra = $scope.extra.trim() if angular.isString($scope.extra)

    return if not uid
    return if not extra

    data = uid: uid, extra: extra
    fundSourceService.add currency, data, (fs) ->
      $scope.uid = ""
      fund_sources.push fs

]
