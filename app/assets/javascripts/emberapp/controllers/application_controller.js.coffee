Peatio.ApplicationController = Ember.Controller.extend
  appName: 'Accounts & Withdraws & Deposits'
  init: ->
    $.subscribe 'flash', (event, data) ->
      $('.flash-messages').show()
      $('#flash-content').html(data.message)
      setTimeout(->
        $('.flash-messages').hide(1000)
      , 10000)


    $.subscribe 'payment_address:create', (event, data) ->
      setTimeout(->
        code = $('#payment_address').html()
        $("#qrcode").attr('data-text', code)
        $("#qrcode").attr('title', code)
        $('.qrcode-container').each (index, el) ->
          $el = $(el)
          new QRCode el,
            text:   $el.data('text')
            width:  $el.data('width')
            height: $el.data('height')
      , 1000)
