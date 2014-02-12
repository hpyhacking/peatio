$ ->
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
