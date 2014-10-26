#= require_tree ./models
#= require_self

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


app = angular.module 'funds', ['templates']


app.directive 'currencyItem', ->
  return {
    restrict: 'E',
    templateUrl: '/templates/currency_item.html'
  }
