angular.module('precisionFilters', []).filter 'round_down', ->
  (number) ->
    BigNumber(number).round(5, BigNumber.ROUND_DOWN).toF(5)
