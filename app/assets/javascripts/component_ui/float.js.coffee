@FloatUI = flight.component ->
  @attributes
    action: 'li'
    close: 'i.fa.fa-close'

  @after 'initialize', ->
    @select('action').click => 
      unless @$node.hasClass('hover')
        @$node.addClass('hover')
      else
        @select('close').click()

    @select('close').click => 
      @$node.removeClass('hover')
      @select('action').removeClass('active')
