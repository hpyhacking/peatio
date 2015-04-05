app.service 'fundSourceService', ['$filter', '$gon', '$resource', 'accountService', ($filter, $gon, $resource, accountService) ->

  resource = $resource '/fund_sources/:id',
    {id: '@id'}
    {update: { method: 'PUT' }}

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

  create: (data, afterCreate) ->
    resource.save data, (fund_source) =>
      $gon.fund_sources.push fund_source
      do @trigger
      do afterCreate if afterCreate

  update: (fund_source, afterUpdate) ->
    resource.update id: fund_source.id, =>
      do @trigger
      do afterUpdate if afterUpdate

  remove: (fund_source, afterRemove) ->
    resource.remove id: fund_source.id, =>
      $gon.fund_sources.splice $gon.fund_sources.indexOf(fund_source), 1
      do @trigger
      do afterRemove if afterRemove

]
