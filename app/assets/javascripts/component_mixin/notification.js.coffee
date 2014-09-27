@NotificationMixin = ->
  @notify = (body, title) ->
    if Cookies('notification') == 'true'
      title ||= gon.i18n.notification.title
      notification = new Notification title, body: body, tag: 1
