app.controller 'WithdrawsController', ['$scope', '$stateParams', '$http', '$gon', 'fundSourceService', 'ngDialog', ($scope, $stateParams, $http, $gon, fundSourceService, ngDialog) ->

  $scope.currency = currency = $stateParams.currency
  $scope.current_user = current_user = $gon.current_user
  $scope.name = current_user.name
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance
  $scope.withdraw_channel = WithdrawChannel.findBy('currency', $scope.currency)

  $scope.fund_sources = -> fundSourceService.filterBy currency:currency

  defaultFundSource = fundSourceService.defaultFundSource currency:currency
  if defaultFundSource
    _selected_fund_source_id = defaultFundSource.id
  else
    fund_sources = $scope.fund_sources()
    _selected_fund_source_id = fund_sources[0].id if fund_sources.length

  $scope.selected_fund_source_id = (newId) ->
    if angular.isDefined(newId)
      _selected_fund_source_id = newId
    else
      _selected_fund_source_id

  @withdraw = {}
  @createWithdraw = (currency) ->
    withdraw_channel = WithdrawChannel.findBy('currency', currency)
    account = withdraw_channel.account()
    data = { withdraw: { member_id: current_user.id, currency: currency, sum: @withdraw.sum, fund_source_id: _selected_fund_source_id } }

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
    else
      template = '/templates/fund_sources/coin.html'

    ngDialog.open
      template:template
      controller: 'FundSourcesController'
      className: 'ngdialog-theme-default custom-width'
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
