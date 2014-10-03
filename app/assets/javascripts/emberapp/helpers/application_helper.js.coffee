Ember.Handlebars.helper 'format-date', (date) ->
  moment(date).format('YYYY-MM-DD HH:mm')
