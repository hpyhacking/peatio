#= require jquery
#= require ./lib/tiny-pubsub
#= require handlebars
#= require ember
#= require ./lib/peatio_model
#= require ./lib/ajax
#= require app
#= require pusher.min
#= require pusher
#= require_self
#= require ./emberapp/peatio

#old

#= require es5-shim.min
#= require es5-sham.min
#= require jquery_ujs
#= require bootstrap
#
#= require moment
#= require underscore
#= require flight
#= require highstock
#= require highstock_config
#= require list
#= require helper
#= require qrcode
#
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui

# for more details see: http://emberjs.com/guides/application/
window.Peatio = Ember.Application.create()
