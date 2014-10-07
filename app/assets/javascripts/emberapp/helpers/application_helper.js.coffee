Ember.Handlebars.helper 'format-date', (date) ->
  moment(date).format('YYYY-MM-DD HH:mm')

Ember.Handlebars.helper 'state-name', (state) ->
  switch state
    when 'submitting' then '已提交'
    when 'cancelled'  then '已撤销'
    when 'submitted'  then '受理中'
    when 'accepted'   then '充值成功'
    when 'rejected'   then '已驳回'
    when 'checked'    then '充值成功'
    when 'warning'    then '异常'
    when 'suspect'    then '异常'


Ember.Handlebars.helper 'account-class', (currency)->
  current_account = window.current_account_action.split(':')[0]
  current_action = window.current_account_action.split(':')[1]

  style = "currency-item"

  if currency == current_account
    style = "#{style} selected #{current_action}-now"

  style
