@ItemListMixin = ->
  @attributes
    tbody: 'table > tbody'
    empty: '.empty-row'

  @checkEmpty = (event, data) ->
    if @select('tbody').find('tr.order').length is 0
      @select('empty').fadeIn()
    else
      @select('empty').fadeOut()

  @addOrUpdateItem = (item) ->
    template = @getTemplate(item)
    existsItem = @select('tbody').find("tr[data-id=#{item.id}][data-kind=#{item.kind}]")

    if existsItem.length
      existsItem.html template.html()
    else
      template.prependTo(@select('tbody')).show('slow')

    @checkEmpty()

  @removeItem = (id) ->
    item = @select('tbody').find("tr[data-id=#{id}]")
    item.hide 'slow', =>
      item.remove()
      @checkEmpty()

  @populate = (event, data) ->
    if not _.isEmpty(data.orders)
      @addOrUpdateItem item for item in data.orders

    @checkEmpty()

