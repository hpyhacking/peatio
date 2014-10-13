Ember.Handlebars.helper 'format-date', (date) ->
  moment(date).format('YYYY-MM-DD HH:mm')

Ember.Handlebars.helper 'deposit-state-name', (state) ->
  switch state
    when 'submitting' then '已提交'
    when 'cancelled'  then '已撤销'
    when 'submitted'  then '受理中'
    when 'accepted'   then '充值成功'
    when 'rejected'   then '已驳回'
    when 'checked'    then '充值成功'
    when 'warning'    then '异常'
    when 'suspect'    then '异常'

Ember.Handlebars.helper 'withdraw-state-name', (state) ->
  switch state
    when 'submitting' then '待确认'
    when 'canceled'  then '已撤销'
    when 'submitted'  then '待校验'
    when 'accepted'   then '已提交'
    when 'rejected'   then '已驳回'
    when 'warning'    then '异常'
    when 'suspect'    then '异常'
    when 'failed'     then '提现出错'
    when 'almost_done' then '发送中'
    when 'done'        then '提现成功'
    when 'processing'  then '受理中'
    when 'coin_ready'  then '准备中'
    when 'coin_done'   then '完毕'


Ember.Handlebars.helper 'account-class', (currency)->
  current_account = window.current_account_action.split(':')[0]
  current_action = window.current_account_action.split(':')[1]

  style = "currency-item"

  if currency == current_account
    style = "#{style} selected #{current_action}-now"

  style

Ember.Handlebars.helper 'to-lower-case',  (str) ->
  str.toLowerCase()
