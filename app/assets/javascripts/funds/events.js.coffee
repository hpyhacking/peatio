$(window).load ->

  # clipboard
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

  # init the two factor auth
  $.subscribe 'two_factor_init', (event, data) ->
    TwoFactorAuth.attachTo('.two-factor-auth-container')

  $.publish 'two_factor_init'
