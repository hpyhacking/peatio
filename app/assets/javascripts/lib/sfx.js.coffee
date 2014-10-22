window.sfx_warning = ->
  window.sfx('warning')

window.sfx_success = ->
  window.sfx('success')

window.sfx = (kind) ->
  s = $("##{kind}-fx")[0]
  return if Cookies.get('sound') == 'false'
  return unless s.play
  s.pause()
  s.currentTime = 0
  s.play()
