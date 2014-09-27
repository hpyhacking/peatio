class Notifier
  constructor: ->
    disableNotification unless window.Notification
    @getState()
    @checkOrRequirePermission()
    $('input[name="notification-checkbox"]').bootstrapSwitch({state: @switchOn(), onSwitchChange: @switch})

  checkOrRequirePermission: =>
    if Notification.permission == 'default'
      @requestPermission(@checkOrRequirePermission)
    else if Notification.permission == 'denied'
      @setStatus(false)
      @removeSwitch()

  removeSwitch: ->
     $('input[name="notification-checkbox"]').remove()

  setState: (status) ->
    @enableNotification = status
    Cookies.set('notification', status, 30)

  getState: ->
    @enableNotification = Cookies.get('notification')

  requestPermission: (callback) ->
    Notification.requestPermission(callback)

  switch: (event, state) =>
    if state
      @setState(true)
    else
      @setState(false)

  switchOn: ->
    if @getState() == "true"
      true
    else
      false

  disableNotification: ->
    $('input[name="notification-checkbox"]').bootstrapSwitch(disabled: true)

  notify: (title, content, logo = '/yunbi_notification_logo.jpg') ->
    if @enableNotification == true || @enableNotification == "true"

      if window.Notification
        popup = new Notification(title, { 'body': content, 'onclick': onclick, 'icon': logo })
      else
        popup = window.webkitNotifications.createNotification(avatar, title, content)

      setTimeout ( => popup.close() ), 8000

window.Notifier = Notifier
