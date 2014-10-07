Peatio.AddressView = Ember.View.extend({
  templateName: 'address',
  didInsertElement: ->
    $.subscribe 'deposit_address:create', (event, data) ->
      $('[data-clipboard-text], [data-clipboard-target]').each ->
        zero = new ZeroClipboard $(@), forceHandCursor: true

        zero.on 'complete', ->
          $(zero.htmlBridge)
            .attr('title', gon.clipboard.done)
            .tooltip('fixTitle')
            .tooltip('show')
        zero.on 'mouseout', ->
          $(zero.htmlBridge)
            .attr('title', gon.clipboard.click)
            .tooltip('fixTitle')

        placement = $(@).data('placement') || 'bottom'
        $(zero.htmlBridge).tooltip({title: gon.clipboard.click, placement: placement})

})
