app.service 'fundSourceService', ['$filter', '$gon', '$resource', 'accountService', ($filter, $gon, $resource, accountService) ->

  resource = $resource '/fund_sources/:id', {id: '@id', currency: '@currency'}
  callbacks = []

  filterBy: (filter) ->
    $filter('filter')($gon.fund_sources, filter)

  findBy: (filter) ->
    result = @filterBy filter
    if result.length then result[0] else null

  defaultSelected: (filter) ->
    account = accountService.findBy filter
    return null if not account
    @findBy id: account.default_withdraw_fund_source_id

  onChange: (callback) ->
    callbacks.push callback
    do callback

  trigger: ->
    do callback for callback in callbacks

  add: (currency, data, afterAdd) ->
    params = currency: currency
    resource.save params, data, (fund_source) =>
      $gon.fund_sources.push fund_source
      do @trigger
      do afterAdd if afterAdd

  remove: (fund_source, afterRemove) ->
    params = id: fund_source.id, currency: fund_source.currency
    resource.remove params, =>
      $gon.fund_sources.splice $gon.fund_sources.indexOf(fund_source), 1
      do @trigger
      do afterRemove if afterRemove

]
