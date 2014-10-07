Peatio.CurrencyItemView = Ember.View.extend
  templateName: 'currency_item'
  didInsertElement: ->
    
    $('.currency-withdraw a').bind('click', ->
      $('.currency-item').removeClass('selected')
      $('.currency-item').removeClass('withdraw-now')
      $('.currency-item').removeClass('deposit-now')

      tr = $(@).parent().parent().parent()
      tr.addClass('selected')
      tr.addClass('withdraw-now')
    )

    $('.currency-deposit a').bind('click', ->
      $('.currency-item').removeClass('selected')
      $('.currency-item').removeClass('withdraw-now')
      $('.currency-item').removeClass('deposit-now')
      tr = $(@).parent().parent().parent()
      tr.addClass('selected')
      tr.addClass('deposit-now')
    )


