#= require jquery
#= require ./lib/peatio_model
#= require ./lib/ajax
#= require handlebars
#= require ember
#= require ember-data
#= require_self
#= require peatio

#old

#= require es5-shim.min
#= require es5-sham.min
#= require jquery_ujs
#= require bootstrap
#
#= require scrollIt
#= require moment
#= require bignumber
#= require underscore
#= require introjs
#= require ZeroClipboard
#= require flight
#= require pusher.min
#= require highstock
#= require highstock_config
#= require list
#= require helper
#= require jquery.mousewheel
#= require qrcode
#
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates

# for more details see: http://emberjs.com/guides/application/
window.Peatio = Ember.Application.create()

Peatio.ApplicationAdapter = DS.FixtureAdapter


