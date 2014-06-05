@ItemListMixin = ->
  @defaultAttrs
    tbody: 'table > tbody'
    empty: '.empty-row'

  @checkEmpty = (event, data) ->
    if @select('tbody').find('tr.order').length is 0
      @select('empty').show()
    else
      @select('empty').hide()

  @addOrUpdateItem = (item) ->
    template = @getTemplate(item)
    existsItem = @select('tbody').find("tr[data-id=#{item.id}-#{item.kind}]")

    if existsItem.length
      existsItem.html template.html()
    else
      template.prependTo(@select('tbody')).show('slow')

    @checkEmpty()

  @removeItem = (id) ->
    item = @select('tbody').find("tr[data-id=#{id}]")
    item.hide 'slow', -> item.remove()
    @checkEmpty()

  @populate = (data) ->
    if not _.isEmpty(data)
      @addOrUpdateItem item for item in data

    @checkEmpty()

