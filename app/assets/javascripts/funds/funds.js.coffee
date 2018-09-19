#= require clipboard
#= require_tree ./models
#= require_tree ./filters
#= require_self
#= require_tree ./config
#= require_tree ./services
#= require_tree ./directives
#= require_tree ./controllers
#= require ./router
#= require ./events

Member.initData         [gon.user]
Deposit.initData         gon.deposits
Account.initData         gon.accounts
Currency.initData        gon.currencies
Withdraw.initData        gon.withdraws

window.app = app = angular.module 'funds', ["ui.router", "ngResource", "translateFilters", "textFilters", "precisionFilters", 'htmlFilters']
