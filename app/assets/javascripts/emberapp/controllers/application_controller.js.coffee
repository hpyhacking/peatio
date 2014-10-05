Peatio.ApplicationController = Ember.Controller.extend
  appName: 'Accounts & Withdraws & Deposits'
  init: ->
    $.subscribe 'flash', (event, data) ->
      $('.flash-message').show()
      $('#flash-content').html(data.message)
      setTimeout(->
        $('.flash-message').hide(1000)
      , 5000)

