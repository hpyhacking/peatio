Peatio.Router.map ->
  @.resource 'accounts', ->
    @.resource 'account', { path: ':currency' }, ->
      @.resource 'withdraws'
      @.resource 'deposits'

