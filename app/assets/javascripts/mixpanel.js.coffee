previous_path = ->
  return unless document.referrer?
  url = document.referrer
  result = url.match(/:\/\/(.[^/]+)(.+)/)
  result[2] if result?

$ ->
  return unless mixpanel?

  if previous_path() == '/signin' && gon.current_user?
    mixpanel.alias gon.current_user.email

  if location.pathname == '/signup'
    mixpanel.track("Sign Up")
