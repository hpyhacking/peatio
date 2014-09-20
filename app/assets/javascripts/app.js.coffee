#= require jquery
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
window.Peatio.ApplicationAdapter = DS.FixtureAdapter
window.store = window.Peatio.__container__.lookup('store:main');

#$ ->
  #Peatio.Member.initData window.current_user
  #Peatio.DepositChannel.initData window.deposit_channels
  #Peatio.Deposit.initData window.deposits
  #Peatio.Account.initData window.accounts
  #Peatio.Currency.initData(<%= raw @currencies.to_json %>)

Peatio.Router.map ->
  @.resource 'currencies', ->
    @.resource 'currency', {path: ':code'}, ->
      @.resource 'withdraws'
      @.resource 'deposits'

Peatio.CurrenciesRoute = Ember.Route.extend
  model: -> 
    window.currencies

Peatio.CurrencyRoute = Ember.Route.extend
  model: (params) ->
    window.currencies[0]
