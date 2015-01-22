@PushButton = flight.component ->
  @attributes
    buttons: '.type-toggle button'

  @setActiveButton = (event) ->
    @select('buttons').removeClass('active')
    $(event.target).closest('button').addClass('active')

  @after 'initialize', ->
    @on @select('buttons'), 'click', @setActiveButton
