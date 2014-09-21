#= require jquery
#= require ./lib/peatio_model
#= require ./lib/ajax
#= require handlebars
#= require ember
#= require ember-data
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
#= require app
#= require pusher
#= require_self


$ ->
  window.pusher_subscriber = new PusherSubscriber()

# for more details see: http://emberjs.com/guides/application/
window.Peatio = Ember.Application.create()
window.Peatio.ApplicationAdapter = DS.FixtureAdapter
window.store = window.Peatio.__container__.lookup('store:main');

Member.initData [window.current_user]
DepositChannel.initData window.deposit_channels
WithdrawChannel.initData window.withdraw_channels
Deposit.initData window.deposits
Account.initData window.accounts
Currency.initData window.currencies
Account.initData window.accounts

Peatio.Router.map ->
  @.resource 'currencies', ->
    @.resource 'currency', { path: ':code' }, ->
      @.resource 'withdraws'
      @.resource 'deposits'


Peatio.ApplicationController = Ember.Controller.extend \
  appName: 'Withdraws & Deposits'

Peatio.ApplicationRoute = Ember.Route.extend
  redirect: ->
    @.transitionTo "/currencies"
  
Peatio.CurrenciesRoute = Ember.Route.extend
  redirect: ->
    @.transitionTo "/currencies/#{Currency.first().code}/deposits"
  model: ->
    Currency.all()

Peatio.CurrencyRoute = Ember.Route.extend
  model: (params) ->
    Currency.findBy 'code', params.code

Peatio.WithdrawsRoute = Ember.Route.extend
  model: (params) ->
    currency = @.modelFor('currency');
    WithdrawChannel.findAllBy 'currency', currency.code

Peatio.DepositsRoute = Ember.Route.extend
  model: (params) ->
    currency = @.modelFor('currency');
    DepositChannel.findAllBy 'currency', currency.code
