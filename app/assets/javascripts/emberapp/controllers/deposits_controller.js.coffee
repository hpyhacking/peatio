Peatio.DepositsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()

    $.subscribe 'deposit:create', ->
      records = controller.get('model')[0].account().deposits()
      record = records.pop()
      controller.get('deposits').insertAt(0, record)

      setTimeout(->
        $('.deposit_item').first().addClass('new-row')
      , 500)

      if controller.get('deposits').length > 3
        setTimeout(->
          controller.get('deposits').popObject()
        , 1000)

      setTimeout(->
        $('.cancel_link:first').bind('click', (event)->
          event.preventDefault()
          event.stopPropagation()
          record_id = event.target.dataset.id
          controller.cancelDepositAction(record_id, event.target)
        )
      , 500)

    $.subscribe 'deposit_address:create', ->
      address = controller.get('model')[0].account().deposit_address
      $("#deposit_address").html(address)
      $('#deposit_address').attr('data-clipboard-text', address)
      $('#qrcode').attr('data-text', address)
      $('#qrcode').attr('title', address)

    setTimeout( ->
      # Thanks to ember that, we can't handle this click by ember's action
      # It won't support firefox to get the event after clicking the link.
      # Fck Ember
      $('.cancel_link').on('click', (event)->
        event.preventDefault()
        event.stopPropagation()
        record_id = event.target.dataset.id
        controller.cancelDepositAction(record_id, event.target)
      )
    , 100)

  depositAddress: (->
    @model[0].account().deposit_address
  ).property('@each')

  btc: (->
    @model[0].currency == "btc"
  ).property('@each')

  cny: (->
    @model[0].currency == "cny"
  ).property('@each')

  deposits: (->
    @model[0].account().topDeposits()
  ).property('@each')

  fsources: (->
    FundSource.findAllBy('currency', @model[0].currency)
  ).property('@each')

  name: (->
    current_user.name
  ).property()

  deposit_channel_key: (->
    @model[0].key
  ).property('@each')

  cancelDepositAction: (record_id, target)->
    url = "/deposits/#{@model[0].resources_name}/#{record_id}"
    $.ajax({
      url: url
      method: 'DELETE'
    }).fail((result) ->
      $.publish 'flash', {message: "服务器忙,请稍后重试"}
    ).done(->
      $(target).remove()
    )

  actions: {
    submitDeposit: ->
      fund_source = $('#fund_source').val()
      sum = $('#deposit_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: sum,  fund_source: fund_source }
      $('#deposit_cny_submit').attr('disabled', 'disabled')
      $.ajax({
        url: "/deposits/#{@model[0].resources_name}",
        method: 'post',
        data: { deposit: data }
      }).always(->
        $('#deposit_cny_submit').removeAttr('disabled')
      ).fail((result) ->
        $.publish 'flash', {message: result.responseText }
      ).done(->
        $('#deposit_sum').val('')
      )

  }
