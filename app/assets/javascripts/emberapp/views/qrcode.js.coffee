Peatio.QrcodeView = Ember.View.extend({
  templateName: 'qrcode',
  didInsertElement: ->
    code = $('#payment_address').html()
    $("#qrcode").attr('data-text', code)
    $("#qrcode").attr('title', code)
    $('.qrcode-container').each (index, el) ->
      $el = $(el)
      new QRCode el,
        text:   $el.data('text')
        width:  $el.data('width')
        height: $el.data('height')
})
