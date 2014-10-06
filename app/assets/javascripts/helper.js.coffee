$.fn.extend
  fixAsk: ->
    if $(@).text().length
      $(@).text(window.fixAsk $(@).text())
    else if $(@).val().length
      $(@).val(window.fixAsk $(@).val())
    $(@)

  fixBid: ->
    if $(@).text().length
      $(@).text(window.fixBid $(@).text())
    else if $(@).val().length
      $(@).val(window.fixBid $(@).val())
    $(@)

window.round = (str, fixed) ->
  BigNumber(str).round(fixed, BigNumber.ROUND_HALF_UP).toF(fixed)

window.fix = (type, str) ->
  str = '0' unless $.isNumeric(str)
  if type is 'ask'
    window.round(str, gon.market.ask.fixed)
  else if type is 'bid'
    window.round(str, gon.market.bid.fixed)

window.fixAsk = (str) ->
  window.fix('ask', str)

window.fixBid = (str) ->
  window.fix('bid', str)

Handlebars.registerHelper 'format_cancel', ->
  gon.i18n.cancel

Handlebars.registerHelper 'format_trade', (ask_or_bid) ->
  gon.i18n[ask_or_bid]

Handlebars.registerHelper 'format_short_trade', (ask_or_bid) ->
  gon.i18n[ask_or_bid][0]

Handlebars.registerHelper 'format_time', (timestamp) ->
  m = moment.unix(timestamp)
  "#{m.format("HH:mm")}#{m.format(":ss")}"

Handlebars.registerHelper 'format_trade_time', (timestamp) ->
  m = moment.unix(timestamp)
  "#{m.format("MM/DD")} #{m.format("HH:mm")}#{m.format(":ss")}"

Handlebars.registerHelper 'format_fulltime', (timestamp) ->
  m = moment.unix(timestamp)
  "#{m.format("MM/DD HH:mm")}"

Handlebars.registerHelper 'format_mask_fixed_price', (price) ->
  fixBid(price).replace(/\..*/, "<g>$&</g>")

Handlebars.registerHelper 'format_long_time', (timestamp) ->
  m = moment.unix(timestamp)
  "#{m.format("YYYY/MM/DD HH:mm")}"

Handlebars.registerHelper 'format_mask_fixed_volume', (volume) ->
  fixAsk(volume).replace(/\..*/, "<g>$&</g>")

Handlebars.registerHelper 'format_fix_ask', (volume) ->
  fixAsk volume

Handlebars.registerHelper 'format_amount', (amount, price) ->
  val = (new BigNumber(amount)).times(new BigNumber(price))
  fixAsk(val).replace(/\..*/, "<g>$&</g>")

Handlebars.registerHelper 'format_trend', (type) ->
  if type == 'buy'
    "text-up"
  else if type == "sell"
    "test-down"

Handlebars.registerHelper 'format_fix_bid', (price) ->
  fixBid price

Handlebars.registerHelper 'format_volume', (origin, volume) ->
  if (origin is volume) or (BigNumber(volume).isZero())
    fixAsk origin
  else
    fixAsk volume

Handlebars.registerHelper 't', (key) -> gon.i18n[key]

