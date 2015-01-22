class Notifier
  constructor: ->
    @removeSwitch() unless window.Notification
    @getState()
    @checkOrRequirePermission()
    $('input[name="notification-checkbox"]').bootstrapSwitch
      labelText: gon.i18n.switch.notification
      state: @switchOn()
      onSwitchChange: @switch

  checkOrRequirePermission: =>
    if @switchOn()
      if Notification.permission == 'default'
        @requestPermission(@checkOrRequirePermission)
      else if Notification.permission == 'denied'
        @setStatus(false)
        @removeSwitch()

  removeSwitch: ->
    $('.desktop-real-notification').remove()

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
      @checkOrRequirePermission()
    else
      @setState(false)

  switchOn: ->
    if @getState() == "true"
      true
    else
      false

  notify: (title, content, logo = '/peatio-notification-logo.png') ->
    if @enableNotification == true || @enableNotification == "true"

      if window.Notification
        popup = new Notification(title, { 'body': content, 'onclick': onclick, 'icon': logo })
      else
        popup = window.webkitNotifications.createNotification(avatar, title, content)

      setTimeout ( => popup.close() ), 8000

window.Notifier = Notifier
