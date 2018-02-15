angular.module('htmlFilters', []).filter 'unsafe', ($sce) ->
  (html) -> $sce.trustAsHtml(html)
