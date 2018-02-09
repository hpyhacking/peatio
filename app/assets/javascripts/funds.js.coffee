#= require yarn_components/raven-js/dist/raven
#= require ./lib/sentry

#= require jquery
#= require pusher.min

#= require ./lib/tiny-pubsub
#= require angular
#= require angular-resource
#= require ./lib/angular-ui-router
#= require ./lib/peatio_model
#= require ./lib/ajax

#= require ./lib/pusher_connection
#= require ./lib/pusher_subscriber

#= require ngDialog/ngDialog

#= require_self
#= require ./funds/funds

#= require es5-shim.min
#= require es5-sham.min
#= require jquery_ujs
#= require bootstrap
#
#= require bignumber
#= require moment
#= require underscore
#= require flight.min
#= require list
#= require qrcode

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui

$(document).on 'click', '[data-clipboard-text], [data-clipboard-target]', (e) ->
  $action = $(this)

  # clipboard.js is initialized so it already listens for clicks.
  return if $action.data('clipboard')

  # Skip click.
  e.preventDefault()
  e.stopPropagation()

  $action.data('clipboard', true)

  # Lazy initialize clipboard.js.
  new Clipboard($action[0])

  # Emulate click.
  $action.click()

setTimeout -> BigNumber.config(ERRORS: false)
