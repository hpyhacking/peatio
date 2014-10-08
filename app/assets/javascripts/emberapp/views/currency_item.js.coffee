Peatio.CurrencyItemView = Ember.View.extend
  templateName: 'currency_item'
  didInsertElement: ->
    $('.currency-withdraw a').bind('click', ->
      tr = $(@).parent().parent().parent()
      if tr.hasClass('selected')
        return
      $('.currency-item').removeClass('selected')
      $('.currency-item').removeClass('withdraw-now')
      $('.currency-item').removeClass('deposit-now')

      tr.addClass('selected')
      tr.addClass('withdraw-now')
      $.publish 'currency:change', tr.data('currency')
    )

    $('.currency-deposit a').bind('click', ->
      $('.currency-item').removeClass('selected')
      $('.currency-item').removeClass('withdraw-now')
      $('.currency-item').removeClass('deposit-now')
      tr = $(@).parent().parent().parent()
      tr.addClass('selected')
      tr.addClass('deposit-now')
      Currency.current = tr.data('currency')
    )


