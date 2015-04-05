app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', ($scope, $gon, fundSourceService) ->

  $scope.banks = $gon.banks
  $scope.currency = currency = $scope.ngDialogData.currency

  $scope.fund_sources = ->
    fundSourceService.filterBy currency:currency

  $scope.defaultFundSource = ->
    fundSourceService.defaultFundSource currency:currency

  $scope.add = ->
    uid   = $scope.uid.trim()   if angular.isString($scope.uid)
    extra = $scope.extra.trim() if angular.isString($scope.extra)

    return if not uid
    return if not extra

    data = uid: uid, extra: extra, currency: currency
    fundSourceService.create data, ->
      $scope.uid = ""
      $scope.extra = "" if currency isnt $gon.fiat_currency

  $scope.remove = (fund_source) ->
    fundSourceService.remove fund_source

  $scope.makeDefault = (fund_source) ->
    fundSourceService.update fund_source

]
