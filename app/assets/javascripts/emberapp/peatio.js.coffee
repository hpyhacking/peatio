#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./components
#= require_tree ./templates
#= require_tree ./routes
#= require ./router
#= require_self
#


$ ->
  window.pusher_subscriber = new PusherSubscriber()

Member.initData [window.current_user]
DepositChannel.initData window.deposit_channels
WithdrawChannel.initData window.withdraw_channels
Deposit.initData window.deposits
Account.initData window.accounts
Currency.initData window.currencies
Withdraw.initData window.withdraws

Peatio.Router.map ->
  @.resource 'accounts', ->
    @.resource 'account', { path: ':currency' }, ->
      @.resource 'withdraws'
      @.resource 'deposits'

Peatio.ApplicationController = Ember.Controller.extend \
  appName: 'Accounts & Withdraws & Deposits'

Peatio.AccountsRoute = Ember.Route.extend
  model: ->
    Account.all()

Peatio.AccountRoute = Ember.Route.extend
  model: (params) ->
    Account.findBy 'currency', params.currency

Peatio.WithdrawsRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('account').withdraw_channels()

Peatio.DepositsRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('account').deposit_channels()

