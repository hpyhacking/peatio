@FloatUI = flight.component ->
  @attributes
    action: 'ul.nav.nav-tabs > li'
    close: 'i.fa.fa-close'

  @after 'initialize', ->
    @select('action').click (e) =>
      if @select('action').length > 1
        if @$node.hasClass('hover') and $(e.currentTarget).hasClass('active')
          @select('close').click()
        else
          @$node.addClass('hover')
      else
        unless @$node.hasClass('hover')
          @$node.addClass('hover')
        else
          @select('close').click()

    @select('close').click =>
      @$node.removeClass('hover')
      @select('action').removeClass('active')
