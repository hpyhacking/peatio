previous_path = ->
  return unless document.referrer?
  url = document.referrer
  url.match(/:\/\/(.[^/]+)(.+)/)[2]

$ ->
  return unless mixpanel?

  if previous_path() == '/signin' && gon.current_user?
    mixpanel.alias gon.current_user.email

  mixpanel.track(location.pathname)
