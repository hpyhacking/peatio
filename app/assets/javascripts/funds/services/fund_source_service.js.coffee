app.service 'fundSourceService', ['$filter', '$gon', ($filter, $gon) ->

  fund_sources = $gon.fund_sources

  filterByCurrency: (currency) ->
    $filter('filter')(fund_sources, currency: currency)

]
