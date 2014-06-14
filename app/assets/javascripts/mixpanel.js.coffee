previous_path = ->
  return unless document.referrer?
  url = document.referrer
  result = url.match(/:\/\/(.[^/]+)(.+)/)
  result[2] if result?

safe_track_links = (sel, eventName) ->
  $(sel).on 'click', (e) ->
    mixpanel.track(eventName)

$ ->
  return unless mixpanel?

  if previous_path() == '/signin' && gon.current_user?
    mixpanel.alias gon.current_user.email

  if location.pathname == '/signup'
    mixpanel.track("Sign Up")

  mixpanel.track_forms("#new_identity", "Sign Up Form Submit")

  safe_track_links '#market .ask-panel', "Ask Panel Click"
  safe_track_links '#market .bid-panel', "Bid Panel Click"
  safe_track_links '#new_order_ask button', "Ask Order Submit"
  safe_track_links '#new_order_bid button', "Bid Order Submit"
