app.controller 'WithdrawsController', ['$scope', '$stateParams', '$http', '$gon', 'fundSourceService', 'ngDialog', ($scope, $stateParams, $http, $gon, fundSourceService, ngDialog) ->

  _selectedFundSourceId = null
  _selectedFundSourceIdInList = (list) ->
    for fs in list
      return true if fs.id is _selectedFundSourceId
    return false

  $scope.currency = currency = $stateParams.currency
  $scope.current_user = current_user = $gon.current_user
  $scope.name = current_user.name
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance
  $scope.withdraw_channel = WithdrawChannel.findBy('currency', $scope.currency)

  $scope.selected_fund_source_id = (newId) ->
    if angular.isDefined(newId)
      _selectedFundSourceId = newId
    else
      _selectedFundSourceId

  $scope.fund_sources = ->
    fund_sources = fundSourceService.filterBy currency:currency
    # reset selected fundSource after add new one or remove previous one
    if not _selectedFundSourceId or not _selectedFundSourceIdInList(fund_sources)
      $scope.selected_fund_source_id fund_sources[0].id if fund_sources.length
    fund_sources

  # set defaultFundSource as selected
  defaultFundSource = fundSourceService.defaultFundSource currency:currency
  if defaultFundSource
    _selectedFundSourceId = defaultFundSource.id
  else
    fund_sources = $scope.fund_sources()
    _selectedFundSourceId = fund_sources[0].id if fund_sources.length

  # set current default fundSource as selected
  $scope.$watch ->
    fundSourceService.defaultFundSource currency:currency
  , (defaultFundSource) ->
    $scope.selected_fund_source_id defaultFundSource.id if defaultFundSource

  @withdraw = {}
  @createWithdraw = (currency) ->
    withdraw_channel = WithdrawChannel.findBy('currency', currency)
    account = withdraw_channel.account()
    data = { withdraw: { member_id: current_user.id, currency: currency, sum: @withdraw.sum, fund_source_id: _selectedFundSourceId } }

    if current_user.app_activated or current_user.sms_activated
      type = $('.two_factor_auth_type').val()
      otp  = $("#two_factor_otp").val()

      data.two_factor = { type: type, otp: otp }
      data.captcha = $('#captcha').val()
      data.captcha_key = $('#captcha_key').val()

    $('.form-submit > input').attr('disabled', 'disabled')

    $http.post("/withdraws/#{withdraw_channel.resource_name}", data)
      .error (responseText) ->
        $.publish 'flash', { message: responseText }
      .finally =>
        @withdraw = {}
        $('.form-submit > input').removeAttr('disabled')
        $.publish 'withdraw:form:submitted'

  @withdrawAll = ->
    @withdraw.sum = Number($scope.account.balance)

  $scope.openFundSourceManagerPanel = ->
    if $scope.currency == $gon.fiat_currency
      template = '/templates/fund_sources/bank.html'
      className = 'ngdialog-theme-default custom-width'
    else
      template = '/templates/fund_sources/coin.html'
      className = 'ngdialog-theme-default custom-width coin'

    ngDialog.open
      template:template
      controller: 'FundSourcesController'
      className: className
      data: {currency: $scope.currency}

  $scope.sms_and_app_activated = ->
    current_user.app_activated and current_user.sms_activated

  $scope.only_app_activated = ->
    current_user.app_activated and !current_user.sms_activated

  $scope.only_sms_activated = ->
    current_user.sms_activated and !current_user.app_activated


  $scope.$watch (-> $scope.currency), ->
    setTimeout(->
      $.publish "two_factor_init"
    , 100)

]
