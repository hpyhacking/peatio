app.controller 'FundSourcesController', ['$scope', '$gon', 'fundSourceService', '$element', ($scope, $gon, fundSourceService, $element) ->

  $scope.currency = currency = $scope.ngDialogData.currency

  $scope.fund_sources = ->
    fundSourceService.filterBy currency: currency

  $scope.defaultFundSource = ->
    fundSourceService.defaultFundSource currency: currency

  $scope.add = ->
    data = currency: currency
    data[name] = (value + '').trim() for {name, value} in $element.find('[name]').serializeArray()

    fundSourceService.create data, -> $element.find('[name]').val('')

  $scope.makeDefault = (fund_source) ->
    fundSourceService.update fund_source

]
