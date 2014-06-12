setupMixpanel = ->
  $ ->
    mixpanel.track(location.pathname)

setupMixpanel()
