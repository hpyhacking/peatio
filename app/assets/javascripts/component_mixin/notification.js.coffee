@NotificationMixin = ->
  @notify = (body, title) ->
    title ||= gon.i18n.notification.title
    notification = notifier.notify(title, body)
