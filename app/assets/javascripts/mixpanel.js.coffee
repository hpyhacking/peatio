$ ->
  return unless mixpanel?
  mixpanel.track(location.pathname)
