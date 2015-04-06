#= require_tree ./models
#= require_tree ./filters
#= require_self
#= require_tree ./services
#= require_tree ./directives
#= require_tree ./controllers
#= require ./router
#= require ./events

$ ->
  window.pusher_subscriber = new PusherSubscriber()

Member.initData         [gon.current_user]
DepositChannel.initData  gon.deposit_channels
WithdrawChannel.initData gon.withdraw_channels
Deposit.initData         gon.deposits
Account.initData         gon.accounts
Currency.initData        gon.currencies
Withdraw.initData        gon.withdraws

window.app = app = angular.module 'funds', ["ui.router", "ngResource", "translateFilters", "textFilters", "precisionFilters", "ngDialog"]

