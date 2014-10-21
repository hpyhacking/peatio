@FloatUI = flight.component ->
  @attributes
    action: 'li'
    close: 'i.fa.fa-close'

  @after 'initialize', ->
    @select('action').click => 
      @$node.addClass('hover')

    @select('close').click => 
      @$node.removeClass('hover')
      @select('action').removeClass('active')
