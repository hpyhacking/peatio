#= require jquery
#= require pusher.min

#= require ./lib/tiny-pubsub
#= require ./lib/handlebars
#= require ./lib/ember
#= require ./lib/peatio_model
#= require ./lib/ajax

#= require ./lib/pusher_connection
#= require ./lib/pusher_subscriber

#= require_self
#= require ./emberapp/peatio

#= require es5-shim.min
#= require es5-sham.min
#= require jquery_ujs
#= require bootstrap
#
#= require bignumber
#= require moment
#= require ZeroClipboard
#= require underscore
#= require flight.min
#= require list
#= require qrcode

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui

# for more details see: http://emberjs.com/guides/application/
window.Peatio = Ember.Application.create()
