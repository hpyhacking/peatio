window.TradeHistoryUI = flight.component ->
  @.defaultAttrs
    table: 'table'
    thead: 'table > thead'
    empty: '.empty-row'
    operation: 'table th.operation'

  @.checkEmpty = (event, data) ->
    $tr = @.select('table').find('tr')
    if $tr.length is 2
      @.select('empty').show()
    else
      @.select('empty').hide()

  @.fixed = (event, data) ->
    $nth = @.select('table').find("tbody > tr:nth-child(#{data})")
    if $nth.length
      $nth.nextAll('tr').remove()

  @.move = (event, data) ->
    $tr = @.select('table').find("tr[data-id=#{data.id}]")
    $tr.hide =>
      $tr.remove()
      @.checkEmpty()

  @.replaceOrNew = (event, data, callback) ->
    @.select('empty').hide()
    $tr = @.select('table').find("tr[data-id=#{data.id}]")

    if $tr.length
      $tr.fadeOut 'slow', =>
        $new = $(JST["trade_history"](data)).hide()
        $tr.replaceWith($new);
        @.select('table').find("tr[data-id=#{data.id}]").fadeIn('slow')
        @.updateOperation()
    else
      data.callback() if data.callback
      $(JST["trade_history"](data)).insertAfter(@.select('empty')).show('slow')
      @.updateOperation()

    

  @.updateOperation = ->
    $operation = @.select('operation')
    @.select('table').find("td.operation > a.#{@.attr.state}").each ->
      $(@).text($operation.data("i18n-#{$(@).data('text')}")).show()

  @.after 'initialize', ->
    if _.isEmpty(@.attr.orders)
      @.select('empty').show()
    else
      @.select('empty').hide()

      for o in @.attr.orders
        $(JST["trade_history"](o)).appendTo(@.select('table').find('tbody')).show('slow')

      @.updateOperation()

    @.on 'check', @.checkEmpty
    @.on 'move', @.move
    @.on 'replaceOrNew', @.replaceOrNew
    @.on 'fixed', @.fixed
