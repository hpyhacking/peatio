Peatio.MemoFieldView = Ember.View.extend({
  templateName: 'memo_field'

  didInsertElement: ->
    currency = $('tr.selected').data('currency')
    if  currency == 'dns' || currency == "btsx"
      $("#memo_field").show()
    else
      $("#memo_field").hide()

    $.subscribe("currency:change", (event, data) ->
      setTimeout( ->
        if data == 'dns' || data == "btsx"
          $("#memo_field").show()
        else
          $("#memo_field").hide()
      , 10)
    )
})
