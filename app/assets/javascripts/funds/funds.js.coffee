#= require_tree ./models
#= require_tree ./filters
#= require_self
#= require_tree ./directives
#= require_tree ./controllers
#= require ./router
#= require ./events

$ ->
  window.pusher_subscriber = new PusherSubscriber()

Member.initData [window.current_user]
DepositChannel.initData window.deposit_channels
WithdrawChannel.initData window.withdraw_channels
Deposit.initData window.deposits
Account.initData window.accounts
Currency.initData window.currencies
Withdraw.initData window.withdraws
FundSource.initData window.fund_sources

window.app = app = angular.module 'funds', ["ui.router", "translateFilters", "textFilters"]
