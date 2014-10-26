@SwitchUI = flight.component ->
  @attributes
    switch: 'li > a'

  @getX = ->
    if Cookies.get(@name())
      Cookies.get(@name())
    else
      @setX(@defaultX())

  @setX = (x) ->
    Cookies.set(@name(), x)
    return x

  @name = ->
    @$node.attr('id')

  @defaultX = ->
    @$node.data('x')

  @after 'initialize', ->
    @on @select('switch'), 'click', (e) =>
      @select('switch').removeClass('active')
      $(e.currentTarget).addClass('active')

      x = $(e.currentTarget).data('x')
      @setX(x)

      @trigger "switch::#{@name()}", {x: x}

    @$node.find("[data-x=#{@getX()}]").click()
