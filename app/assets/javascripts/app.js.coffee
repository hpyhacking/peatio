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

Peatio.ApplicationAdapter = DS.FixtureAdapter

# Model
#

attr = DS.attr
hasMany = DS.hasMany
belongsTo = DS.belongsTo


# Member Model
Peatio.Member = DS.Model.extend
  sn: attr()
  display_name: attr()
  email: attr()
  created_at: attr()
  updated_at: attr()
  state: attr()
  country_code: attr()
  phone_number: attr()

Peatio.Member.reopenClass
  initData: (data) ->
    window.store.createRecord('member', data)

# DepositChannel Model
Peatio.DepositChannel = DS.Model.extend
  key: attr()
  currency: attr()
  min_confirm: attr()
  max_confirm: attr()
  bank_accounts: attr()

Peatio.DepositChannel.reopenClass
  initData: (data) ->
    window.store.createRecord('deposit-channel', item.attributes) for item in data

# Deposit Model
Peatio.Deposit = DS.Model.extend
  account_id: attr()
  member_id: attr()
  currency: attr()
  amount: attr()
  fee: attr()
  fund_uid: attr()
  fund_extra: attr()
  txid: attr()
  state: attr()
  aasm_state: attr()
  created_at: attr()
  updated_at: attr()
  done_at: attr()
  memo: attr()
  type: attr()

Peatio.Deposit.reopenClass
  initData: (data) ->
    window.store.createRecord('deposit', item) for item in data

# Account Model
Peatio.Account = DS.Model.extend
  member_id: attr()
  currency: attr()
  balance: attr()
  locked: attr()
  created_at: attr()
  updated_at: attr()
  in: attr()
  out: attr()

Peatio.Account.reopenClass
  initData: (data) ->
    window.store.createRecord('account', item) for item in data

