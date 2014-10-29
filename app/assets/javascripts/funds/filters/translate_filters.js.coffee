angular.module('translateFilters', []).filter 't', ->
  (key) ->
    I18n.t(key)
