app.service 'fundSourceService', ['$resource', ($resource) ->

  resource = $resource '/fund_sources/:id', {id: '@id', currency: '@currency'}

  add: (currency, uid, extra, success) ->
    uid = uid.trim()
    return if uid is ""

    params = currency: currency
    data = uid: uid, extra: extra
    resource.save params, data, success

  remove: (fund_source, success) ->
    params = id: fund_source.id, currency: fund_source.currency
    resource.remove params, success

]
