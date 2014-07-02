previous_path = ->
  return unless document.referrer?
  url = document.referrer
  result = url.match(/:\/\/(.[^/]+)(.+)/)
  result[2] if result?

safe_track_links = (sel, eventName) ->
  $(sel).on 'click', (e) ->
    mixpanel.track eventName

track_order_submit = (type) ->
  formSel   = "#new_order_#{type}"
  buttonSel = "#{formSel} button[type=submit]"

  $(buttonSel).on 'click', (e) ->
    mixpanel.track "Order Submit",
      type: type,
      price: $("#order_#{type}_price").val(),
      volume: $("#order_#{type}_origin_volume").val(),
      total: $("#order_#{type}_sum").val()

$ ->
  return unless mixpanel?

  if previous_path() == '/signin' && gon.current_user?
    mixpanel.alias gon.current_user.email

  if location.pathname == '/signup'
    mixpanel.track("Sign Up")
    mixpanel.track_forms("#new_identity", "Sign Up Form Submit")

  track_order_submit 'ask'
  track_order_submit 'bid'
