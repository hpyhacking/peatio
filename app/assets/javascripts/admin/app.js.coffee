$ ->
  $('input[name*=created_at]').datetimepicker()

  $('[data-clipboard-text], [data-clipboard-target]').each ->
    zero = new ZeroClipboard($(@))

    zero.on 'complete', ->
      $(zero.htmlBridge)
        .attr('title', 'done')
        .tooltip('fixTitle')
        .tooltip('show')
    zero.on 'mouseout', ->
      $(zero.htmlBridge)
        .attr('title', 'copy')
        .tooltip('fixTitle')

    placement = $(@).data('placement') || 'bottom'
    $(zero.htmlBridge).tooltip({title: 'copy', placement: placement})
