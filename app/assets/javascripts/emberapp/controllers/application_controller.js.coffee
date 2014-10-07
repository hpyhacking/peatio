Peatio.ApplicationController = Ember.Controller.extend
  appName: 'Accounts & Withdraws & Deposits'
  init: ->
    $.subscribe 'flash', (event, data) ->
      $('.flash-messages').show()
      $('#flash-content').html(data.message)
      setTimeout(->
        $('.flash-messages').hide(1000)
      , 10000)



