app.config ['ngDialogProvider', (ngDialogProvider) ->
  ngDialogProvider.setDefaults
    closeByDocument: false
    closeByEscape: false
    trapFocus: true
    cache: false
]
