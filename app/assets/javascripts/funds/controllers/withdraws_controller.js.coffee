app.controller 'WithdrawsController', ['$scope', '$stateParams', '$http', '$gon', 'ngDialog', ($scope, $stateParams, $http, $gon, ngDialog) ->
  @withdraw = {}
  $scope.currency = $stateParams.currency
  $scope.current_user = current_user = $gon.current_user
  $scope.name = current_user.name
  $scope.fsources = FundSource.findAllBy('currency', $scope.currency)
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance
  $scope.withdraw_channel = WithdrawChannel.findBy('currency', $scope.currency)

  @createWithdraw = (currency) ->
    ctrl = @
    withdraw_channel = WithdrawChannel.findBy('currency', currency)
    account = withdraw_channel.account()

    data = { withdraw: { member_id: current_user.id, currency: currency, sum: @withdraw.sum, fund_source: @withdraw.fund_source } }

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
      .finally ->
        priorSelectedFundSource = ctrl.withdraw.fund_source
        ctrl.withdraw = {}
        ctrl.withdraw.fund_source = priorSelectedFundSource
        $('.form-submit > input').removeAttr('disabled')
        $.publish 'withdraw:form:submitted'

  @withdrawAll = ->
    @withdraw.sum = Number($scope.account.balance)

  $scope.openFundSourceManagerPanel = ->
    ngDialog.open
      template: '/templates/fund_sources/index.html'
      controller: 'FundSourcesController'
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
