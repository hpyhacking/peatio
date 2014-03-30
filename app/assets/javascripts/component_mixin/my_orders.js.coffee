@MyOrdersMixin = ->
  @defaultAttrs
    table: 'table > tbody'
    empty: '.empty-row'

  @checkEmpty = (event, data) ->
    if @select('table').find('tr.order').length is 0
      @select('empty').show()
    else
      @select('empty').hide()

  @populate = (data) ->
    if _.isEmpty(data)
      @select('empty').show()
    else
      @select('empty').hide()

      for order in data
        @getTemplate(order).prependTo(@select('table')).show('slow')

  @addOrUpdateOrder = (order) ->
    template = @getTemplate(order)
    existsOrder = @select('table').find("tr[data-id=#{order.id}]")

    if existsOrder.length
      existsOrder.html template.html()
    else
      template.appendTo(@select('table')).show('slow')

    @checkEmpty()

  @removeOrder = (order) ->
    $tr = @.select('table').find("tr[data-id=#{order.id}]")
    $tr.hide =>
      $tr.remove()
      @checkEmpty()

