angular.module('textFilters', []).filter 'truncate', ->
  (text, size) ->
    if text.length > 20
      text.slice(0, size) + '...'
    else
      text
