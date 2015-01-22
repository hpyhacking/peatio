angular.module('translateFilters', []).filter 't', ->
  (key, args={}) ->
    I18n.t(key, args)
