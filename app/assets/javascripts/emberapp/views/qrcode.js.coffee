Peatio.QrcodeView = Ember.View.extend({
  templateName: 'qrcode',
  didInsertElement: ->
    if $("#payment_address").html().length > 0 and $("#payment_address img").length == 0
      $.publish 'payment_address:create'
})
