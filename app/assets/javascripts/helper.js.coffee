$ ->
  $.fn.extend
    fixAsk: ->
      if $(@).text().length
        $(@).text(window.fixAsk $(@).text())
      else if $(@).val().length
        val = window.fixAsk $(@).val()
        $(@).val(val)
      $(@)

    fixBid: ->
      if $(@).text().length
        $(@).text(window.fixBid $(@).text())
      else if $(@).val().length
        val = window.fixBid $(@).val()
        $(@).val(val)
      $(@)

  window.round = (str, fixed) ->
    zero = Array(fixed - 1).join("0")
    numeral(BigNumber(str).round(fixed, 1).toString()).format("0.00[#{zero}]")

  window.fix = (type, str) ->
    if type is 'ask'
      window.round(str, gon.market.ask.fixed)
    else if type is 'bid'
      window.round(str, gon.market.bid.fixed)

  window.fixAsk = (str) ->
    window.fix('ask', str)

  window.fixBid = (str) ->
    window.fix('bid', str)

  Handlebars.registerHelper 'format_trade', (ask_or_bid) ->
    gon.i18n[ask_or_bid]

  Handlebars.registerHelper 'format_time', (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("HH:mm")}#{m.format(":ss")}"

  Handlebars.registerHelper 'format_fulltime', (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("YY-MM-DD HH:mm")}#{m.format(":ss")}"

  Handlebars.registerHelper 'format_mask_number', (number, length = 7) ->
    fractional_len = length - 2
    fractional_part = Array(fractional_len).join '0'
    numeral(number).format("0.#{fractional_part}").substr(0, length).replace(/\..*/, "<g>$&</g>")

  Handlebars.registerHelper 'format_mask_fixed_number', (number, length = 4) ->
    fractional_part = Array(length).join '0'
    numeral(number).format("0.#{fractional_part}").replace(/\..*/, "<g>$&</g>")

  Handlebars.registerHelper 'format_fix_ask', (volume) ->
    fixAsk volume

  Handlebars.registerHelper 'format_fix_bid', (price) ->
    fixAsk price

  Handlebars.registerHelper 'format_volume', (origin, volume) ->
    if (origin is volume) or (BigNumber(volume).isZero())
      fixAsk origin
    else
      "#{fixAsk volume} / #{fixAsk origin}"
