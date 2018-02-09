$(window).load ->

  # qrcode
  $.subscribe 'deposit_address:create', (event, data) ->
    code = if data then data else $('#deposit_address').html()

    $("#qrcode").attr('data-text', code)
    $("#qrcode").attr('title', code)
    $('.qrcode-container').each (index, el) ->
      $el = $(el)
      $("#qrcode img").remove()
      $("#qrcode canvas").remove()

      new QRCode el,
        text:   $("#qrcode").attr('data-text')
        width:  $el.data('width')
        height: $el.data('height')

  $.publish 'deposit_address:create'

  # flash message
  $.subscribe 'flash', (event, data) ->
    $('.flash-messages').show()
    $('#flash-content').html(data.message)
    setTimeout(->
      $('.flash-messages').hide(1000)
    , 10000)
