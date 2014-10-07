Peatio.QrcodeView = Ember.View.extend({
  templateName: 'qrcode',
  didInsertElement: ->
    $.subscribe 'payment_address:create', (event, data) ->
      code = $('#payment_address').html()
      $("#qrcode").attr('data-text', code)
      $("#qrcode").attr('title', code)
      $('.qrcode-container').each (index, el) ->
        $el = $(el)
        new QRCode el,
          text:   $el.data('text')
          width:  $el.data('width')
          height: $el.data('height')


    if $("#payment_address").html().length > 0
      $.publish 'payment_address:create'
})
