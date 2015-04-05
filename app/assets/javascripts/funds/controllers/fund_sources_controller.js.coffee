app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', ($scope, $gon, fundSourceService) ->

  $scope.banks = $gon.banks
  $scope.currency = currency = $scope.ngDialogData.currency
  $scope.fund_sources = fund_sources = []
  $scope.defaultSelected = defaultSelected = fundSourceService.defaultSelected currency:currency

  fundSourceService.onChange ->
    fund_sources.splice(0, fund_sources.length) if fund_sources.length
    fund_sources.push i for i in fundSourceService.filterBy currency:currency
    defaultSelected = fundSourceService.defaultSelected currency:currency

  $scope.add = ->
    uid   = $scope.uid.trim()   if angular.isString($scope.uid)
    extra = $scope.extra.trim() if angular.isString($scope.extra)

    return if not uid
    return if not extra

    data = uid: uid, extra: extra
    fundSourceService.add currency, data, ->
      $scope.uid = ""
      $scope.extra = "" if currency isnt $gon.fiat_currency

  $scope.remove = (fund_source) ->
    fundSourceService.remove fund_source

  $scope.makeDefault = (fs) ->
    console.info fs

]
