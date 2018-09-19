#= require yarn_components/raven-js/dist/raven
#= require ./lib/sentry

#= require jquery

#= require ./lib/tiny-pubsub
#= require angular
#= require angular-resource
#= require ./lib/angular-ui-router
#= require ./lib/peatio_model
#= require ./lib/ajax

#= require_self
#= require ./funds/funds

#= require jquery_ujs
#= require bootstrap
#
#= require bignumber
#= require underscore
#= require qrcode

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
