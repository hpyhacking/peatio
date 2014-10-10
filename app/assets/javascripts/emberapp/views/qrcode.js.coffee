Peatio.QrcodeView = Ember.View.extend({
  templateName: 'qrcode',
  didInsertElement: ->
    if $("#deposit_address").html().length > 0 and $("#deposit_address img").length == 0
      $.publish 'deposit_address:create'
})
