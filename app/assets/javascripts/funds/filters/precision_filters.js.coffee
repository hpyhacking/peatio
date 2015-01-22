angular.module('precisionFilters', []).filter 'round_down', ->
  (number) ->
    BigNumber(number).round(3, BigNumber.ROUND_DOWN).toS()

