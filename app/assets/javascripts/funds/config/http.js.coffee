app.config ['$httpProvider', ($httpProvider) ->

  $httpProvider.defaults.headers.common['X-CSRF-Token'] =
    document.querySelector('meta[name="csrf-token"]').getAttribute('content')

]